/**
 * @name Denial of Service via Unicode Character Processing
 * @description Detects when remote user-controlled input undergoes expensive Unicode normalization (NFKC/NFKD). 
 *              These operations can cause denial-of-service through attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) may triple payload size during normalization.
 * @kind path-problem
 * @id py/unicode-dos
 * @precision high
 * @problem.severity error
 * @tags security
 *       experimental
 *       external/cwe/cwe-770
 */

import python
import semmle.python.ApiGraphs
import semmle.python.Concepts
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.RemoteFlowSources

// Represents Unicode normalization function calls from unicodedata, unidecode, pyunormalize, and textnorm modules.
// normalizedArgIndex specifies which argument contains the string to be normalized.
class UnicodeNormalizationCall extends API::CallNode {
  int normalizedArgIndex; // Index of the argument undergoing normalization

  UnicodeNormalizationCall() {
    // Scenario 1: normalize() calls with NFKC/NFKD form (2nd argument normalized)
    (
      this = API::moduleImport("unicodedata").getMember("normalize").getACall() and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
      or
      this = API::moduleImport("pyunormalize").getMember("normalize").getACall() and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
    ) and
    normalizedArgIndex = 1
    or
    // Scenario 2: Other normalization calls where 1st argument is normalized
    (
      this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
      this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
      or
      this = API::moduleImport("unidecode").getMember("unidecode").getACall()
      or
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    normalizedArgIndex = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizedArgIndex) 
  }
}

// Identifies guard conditions enforcing size limits on input values
predicate inputSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchCondition) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (operator instanceof LtE or operator instanceof Lt) and
        branchCondition = true and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (operator instanceof GtE or operator instanceof Gt) and
        branchCondition = true and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (operator instanceof GtE or operator instanceof Gt) and
        branchCondition = false and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (operator instanceof LtE or operator instanceof Lt) and
        branchCondition = false and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlledNode = lengthCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSTaintConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Size limit checks prevent uncontrolled input expansion
    barrier = DataFlow::BarrierGuard<inputSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeNormalizationCall normalizationCall).getNormalizedArgument()
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    sink = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    sink =
      API::moduleImport("werkzeug")
          .getMember("utils")
          .getMember("secure_filename")
          .getACall()
          .getArg(_)
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking using Unicode DoS configuration
module UnicodeDoSTaintFlow = TaintTracking::Global<UnicodeDoSTaintConfig>;

import UnicodeDoSTaintFlow::PathGraph

from UnicodeDoSTaintFlow::PathNode sourcePathNode, UnicodeDoSTaintFlow::PathNode sinkPathNode
where UnicodeDoSTaintFlow::flowPath(sourcePathNode, sinkPathNode)
select sinkPathNode.getNode(), sourcePathNode, sinkPathNode, "This $@ can reach a $@.", sourcePathNode.getNode(),
  "user-provided value", sinkPathNode.getNode(), "costly Unicode normalization operation"