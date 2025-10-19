/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies when remote user-supplied input is processed by expensive Unicode normalization operations (NFKC/NFKD). 
 *              These operations can trigger denial of service on Windows through attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) may triple the payload size during normalization.
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

// Represents calls to Unicode compatibility normalization functions from 
// unicodedata, unidecode, pyunormalize, and textnorm modules.
// The targetArgIndex identifies which argument contains the string to normalize.
class UnicodeNormCall extends API::CallNode {
  int targetArgIndex; // Index of the argument being normalized

  UnicodeNormCall() {
    // Case 1: normalize() calls where form is NFKC/NFKD (2nd argument normalized)
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
    targetArgIndex = 1
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
    targetArgIndex = 0
  }

  DataFlow::Node getTargetArgument() { 
    result = this.getArg(targetArgIndex) 
  }
}

// Identifies guard conditions that enforce size limits on input values
predicate sizeLimitGuardExists(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branchVal) {
  exists(CompareNode cmpNode | cmpNode = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (op instanceof LtE or op instanceof Lt) and
        branchVal = true and
        cmpNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (op instanceof GtE or op instanceof Gt) and
        branchVal = true and
        cmpNode.operands(_, op, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (op instanceof GtE or op instanceof Gt) and
        branchVal = false and
        cmpNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (op instanceof LtE or op instanceof Lt) and
        branchVal = false and
        cmpNode.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Configuration for taint tracking analysis of Unicode DoS vulnerabilities
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { 
    src instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Size limit checks prevent uncontrolled input growth
    barrier = DataFlow::BarrierGuard<sizeLimitGuardExists/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeNormCall normCall).getTargetArgument()
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

// Global taint tracking analysis using the Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"