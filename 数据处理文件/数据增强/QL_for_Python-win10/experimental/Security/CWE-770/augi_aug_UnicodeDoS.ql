/**
 * @name Denial of Service using Unicode Characters
 * @description Identifies when remote user input reaches expensive Unicode normalization operations (NFKC/NFKD). 
 *              These operations can trigger denial of service on Windows through attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) can triple payload size during normalization.
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

// Represents Unicode compatibility normalization calls from 
// unicodedata, unidecode, pyunormalize, and textnorm modules.
// normalizedArgPos identifies the argument index containing the string to normalize.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedArgPos; // Position of the argument being normalized

  UnicodeCompatibilityNormalizationCall() {
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
    normalizedArgPos = 1
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
    normalizedArgPos = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizedArgPos) 
  }
}

// Detects guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branchVal) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (op instanceof LtE or op instanceof Lt) and
        branchVal = true and
        comparison.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (op instanceof GtE or op instanceof Gt) and
        branchVal = true and
        comparison.operands(_, op, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (op instanceof GtE or op instanceof Gt) and
        branchVal = false and
        comparison.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (op instanceof LtE or op instanceof Lt) and
        branchVal = false and
        comparison.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Size limit checks prevent uncontrolled input expansion
    barrier = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeCompatibilityNormalizationCall ucnCall).getNormalizedArgument()
    or
    // werkzeug's secure_filename() internally uses Unicode normalization
    exists(API::CallNode werkzeugCall |
      werkzeugCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall() and
      sink = werkzeugCall.getArg(_)
    )
    or
    exists(API::CallNode werkzeugUtilsCall |
      werkzeugUtilsCall = API::moduleImport("werkzeug")
          .getMember("utils")
          .getMember("secure_filename")
          .getACall() and
      sink = werkzeugUtilsCall.getArg(_)
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