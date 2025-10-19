/**
 * @name Denial of Service using Unicode Characters
 * @description Detects paths where user-controlled input reaches Unicode normalization operations
 *              (NFKC/NFKD) that could cause denial of service. These operations may exponentially
 *              increase payload size (e.g., U+2100 ℀ triples in size during normalization).
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

// Represents Unicode normalization function calls processing compatibility characters
// (NFKC/NFKD forms). Tracks which argument contains the string to be normalized.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedStringArgIndex; // Position of the normalized string argument

  UnicodeCompatibilityNormalizationCall() {
    // Case 1: normalize() calls with explicit NFKC/NFKD form (2nd arg normalized)
    (
      this = API::moduleImport("unicodedata").getMember("normalize").getACall()
      or
      this = API::moduleImport("pyunormalize").getMember("normalize").getACall()
    ) and
    this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
        "NFKC", "NFKD"
      ] and
    normalizedStringArgIndex = 1
    or
    // Case 2: Direct normalization calls (1st arg normalized)
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
    normalizedStringArgIndex = 0
  }

  // Retrieves the argument node containing the string to normalize
  DataFlow::Node getNormalizedStringArg() { 
    result = this.getArg(normalizedStringArgIndex) 
  }
}

// Detects guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branch) {
  exists(CompareNode compareNode | compareNode = guard |
    exists(API::CallNode lengthCall, Cmpop compareOperator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (compareOperator instanceof LtE or compareOperator instanceof Lt) and
        branch = true and
        compareNode.operands(lengthNode.asCfgNode(), compareOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (compareOperator instanceof GtE or compareOperator instanceof Gt) and
        branch = true and
        compareNode.operands(_, compareOperator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (compareOperator instanceof GtE or compareOperator instanceof Gt) and
        branch = false and
        compareNode.operands(lengthNode.asCfgNode(), compareOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (compareOperator instanceof LtE or compareOperator instanceof Lt) and
        branch = false and
        compareNode.operands(_, compareOperator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlled = lengthCall.getArg(0).asCfgNode()
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
    // Direct normalization calls
    exists(UnicodeCompatibilityNormalizationCall normCall |
      sink = normCall.getNormalizedStringArg()
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
      sink = werkzeugCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode pathSource, UnicodeDoSFlow::PathNode pathSink
where UnicodeDoSFlow::flowPath(pathSource, pathSink)
select pathSink.getNode(), pathSource, pathSink, "This $@ can reach a $@.", pathSource.getNode(),
  "user-provided value", pathSink.getNode(), "costly Unicode normalization operation"