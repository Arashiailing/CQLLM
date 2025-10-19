/**
 * @name Denial of Service using Unicode Characters
 * @description Identifies paths where remote user input reaches Unicode normalization operations
 *              (NFKC/NFKD) that can cause denial of service. These operations can exponentially
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

// Represents Unicode normalization function calls that process compatibility characters
// (NFKC/NFKD forms). Tracks which argument contains the string to be normalized.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedArgPosition; // Position of the normalized string argument

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
    normalizedArgPosition = 1
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
    normalizedArgPosition = 0
  }

  // Retrieves the argument node containing the string to normalize
  DataFlow::Node getNormalizedStringArg() { 
    result = this.getArg(normalizedArgPosition) 
  }
}

// Detects guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchValue) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (op instanceof LtE or op instanceof Lt) and
        branchValue = true and
        comparisonNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (op instanceof GtE or op instanceof Gt) and
        branchValue = true and
        comparisonNode.operands(_, op, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (op instanceof GtE or op instanceof Gt) and
        branchValue = false and
        comparisonNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (op instanceof LtE or op instanceof Lt) and
        branchValue = false and
        comparisonNode.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlledNode = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierGuardNode) {
    // Size limit checks prevent uncontrolled input expansion
    barrierGuardNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkArgNode) {
    // Direct normalization calls
    exists(UnicodeCompatibilityNormalizationCall normCall |
      sinkArgNode = normCall.getNormalizedStringArg()
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
      sinkArgNode = werkzeugCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"