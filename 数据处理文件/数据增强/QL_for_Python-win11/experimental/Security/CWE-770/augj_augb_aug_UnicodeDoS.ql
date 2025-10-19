/**
 * @name Denial of Service via Unicode Character Processing
 * @description Detects remote user input processed by expensive Unicode normalization (NFKC/NFKD). 
 *              These operations can cause denial of service on Windows via attacks like 
 *              "One Million Unicode Characters". Special characters (e.g., U+2100 ℀ or U+2105 ℅) 
 *              may triple payload size during normalization.
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

// Represents Unicode normalization function calls from unicodedata, unidecode, 
// pyunormalize, and textnorm modules. normalizedArgIndex identifies which 
// argument contains the string to normalize.
class UnicodeNormCall extends API::CallNode {
  int normalizedArgIndex; // Index of the argument being normalized

  UnicodeNormCall() {
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

  DataFlow::Node getTargetArgument() { 
    result = this.getArg(normalizedArgIndex) 
  }
}

// Identifies guard conditions enforcing size limits on input values
predicate sizeLimitGuardExists(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branchVal) {
  exists(CompareNode comparisonNode | comparisonNode = guard |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (operator instanceof LtE or operator instanceof Lt) and
        branchVal = true and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (operator instanceof GtE or operator instanceof Gt) and
        branchVal = true and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (operator instanceof GtE or operator instanceof Gt) and
        branchVal = false and
        comparisonNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (operator instanceof LtE or operator instanceof Lt) and
        branchVal = false and
        comparisonNode.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlled = lengthCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size limit checks prevent uncontrolled input expansion
    barrierNode = DataFlow::BarrierGuard<sizeLimitGuardExists/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct Unicode normalization calls
    sinkNode = any(UnicodeNormCall normCall).getTargetArgument()
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    sinkNode = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    sinkNode =
      API::moduleImport("werkzeug")
          .getMember("utils")
          .getMember("secure_filename")
          .getACall()
          .getArg(_)
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using the Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"