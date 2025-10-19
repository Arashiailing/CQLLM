/**
 * @name Denial of Service via Unicode Character Processing
 * @description Detects remote user input processed by expensive Unicode normalization (NFKC/NFKD).
 *              These operations can cause DoS via attacks like "One Million Unicode Characters".
 *              Special chars (e.g., U+2100 ℀ or U+2105 ℅) may triple payload size during normalization.
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

// Represents calls to Unicode normalization functions from unicodedata, unidecode, 
// pyunormalize, and textnorm modules. normalizedArgIndex identifies which argument 
// contains the string to be normalized.
class UnicodeNormalizationCall extends API::CallNode {
  int normalizedArgIndex; // Index of argument being normalized

  UnicodeNormalizationCall() {
    // Case 1: normalize() calls with NFKC/NFKD form (2nd argument normalized)
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
    // Case 2: Other normalization calls where 1st argument is normalized
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
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlledNode, boolean branchValue) {
  exists(CompareNode comparisonNode | comparisonNode = guard |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (operator instanceof LtE or operator instanceof Lt) and
        branchValue = true and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (operator instanceof GtE or operator instanceof Gt) and
        branchValue = true and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (operator instanceof GtE or operator instanceof Gt) and
        branchValue = false and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (operator instanceof LtE or operator instanceof Lt) and
        branchValue = false and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlledNode = lengthCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node guardBarrier) {
    // Size limit checks prevent uncontrolled input growth
    guardBarrier = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct Unicode normalization calls
    sinkNode = any(UnicodeNormalizationCall unicodeNormCall).getNormalizedArgument()
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    exists(API::CallNode werkzeugCall |
      werkzeugCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
      or
      werkzeugCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
    |
      sinkNode = werkzeugCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode sourceNode, UnicodeDoSFlow::PathNode sinkNode
where UnicodeDoSFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "This $@ can reach a $@.", sourceNode.getNode(),
  "user-provided value", sinkNode.getNode(), "costly Unicode normalization operation"