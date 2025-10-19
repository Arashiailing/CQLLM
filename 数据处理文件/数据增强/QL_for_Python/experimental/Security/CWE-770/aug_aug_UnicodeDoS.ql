/**
 * @name Denial of Service using Unicode Characters
 * @description Detects when remote user-controlled data reaches costly Unicode normalization operations (NFKC/NFKD). 
 *              Such operations can cause denial of service on Windows via attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) can triple payload size.
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
// The normalizedParamIndex identifies which argument contains the string to normalize.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedParamIndex; // Index of the argument being normalized

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
    normalizedParamIndex = 1
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
    normalizedParamIndex = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizedParamIndex) 
  }
}

// Identifies guard conditions that enforce size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branchVal) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lenCall, Cmpop operator, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (operator instanceof LtE or operator instanceof Lt) and
        branchVal = true and
        comparison.operands(lenNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (operator instanceof GtE or operator instanceof Gt) and
        branchVal = true and
        comparison.operands(_, operator, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (operator instanceof GtE or operator instanceof Gt) and
        branchVal = false and
        comparison.operands(lenNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (operator instanceof LtE or operator instanceof Lt) and
        branchVal = false and
        comparison.operands(_, operator, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Configuration for taint tracking analysis of Unicode DoS vulnerabilities
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node srcNode) { 
    srcNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size limit checks prevent uncontrolled input growth
    barrierNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    exists(UnicodeCompatibilityNormalizationCall ucnCall |
      sinkNode = ucnCall.getNormalizedArgument()
    )
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    exists(API::CallNode werkzeugCall |
      (
        werkzeugCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        werkzeugCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
      ) and
      sinkNode = werkzeugCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using the Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"