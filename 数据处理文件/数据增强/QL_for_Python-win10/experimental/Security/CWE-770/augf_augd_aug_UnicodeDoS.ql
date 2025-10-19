/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies when user-controlled input reaches computationally expensive Unicode normalization operations (NFKC/NFKD). 
 *              These operations can trigger denial of service on Windows through attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) can expand payload size by up to 3x.
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
// The argIndexForNormalization identifies which argument contains the string to normalize.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int argIndexForNormalization; // Index of the argument being normalized

  UnicodeCompatibilityNormalizationCall() {
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
    argIndexForNormalization = 1
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
    argIndexForNormalization = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(argIndexForNormalization) 
  }
}

// Identifies guard conditions that enforce size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branchOutcome) {
  exists(CompareNode compNode | compNode = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (op instanceof LtE or op instanceof Lt) and
        branchOutcome = true and
        compNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (op instanceof GtE or op instanceof Gt) and
        branchOutcome = true and
        compNode.operands(_, op, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (op instanceof GtE or op instanceof Gt) and
        branchOutcome = false and
        compNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (op instanceof LtE or op instanceof Lt) and
        branchOutcome = false and
        compNode.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Configuration for taint tracking analysis of Unicode DoS vulnerabilities
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Size limit checks prevent uncontrolled input growth
    barrier = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeCompatibilityNormalizationCall ucnCall).getNormalizedArgument()
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
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode sourcePath, UnicodeDoSFlow::PathNode sinkPath
where UnicodeDoSFlow::flowPath(sourcePath, sinkPath)
select sinkPath.getNode(), sourcePath, sinkPath, "This $@ can reach a $@.", sourcePath.getNode(),
  "user-provided value", sinkPath.getNode(), "costly Unicode normalization operation"