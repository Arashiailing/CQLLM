/**
 * @name Denial of Service via Unicode Character Processing
 * @description Detects data flow paths where untrusted user inputs reach Unicode normalization
 *              operations (NFKC/NFKD) that could cause denial of service. These operations
 *              may exponentially expand input size (e.g., U+2100 ℀ triples during normalization).
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
  int argIndexForNormalization; // Position of the normalized string argument

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
    argIndexForNormalization = 1
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
    argIndexForNormalization = 0
  }

  // Retrieves the argument node containing the string to normalize
  DataFlow::Node getTargetStringArg() { 
    result = this.getArg(argIndexForNormalization) 
  }
}

// Detects guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchValue) {
  exists(CompareNode compareNode | compareNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop compareOperator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (compareOperator instanceof LtE or compareOperator instanceof Lt) and
        branchValue = true and
        compareNode.operands(lengthNode.asCfgNode(), compareOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (compareOperator instanceof GtE or compareOperator instanceof Gt) and
        branchValue = true and
        compareNode.operands(_, compareOperator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (compareOperator instanceof GtE or compareOperator instanceof Gt) and
        branchValue = false and
        compareNode.operands(lengthNode.asCfgNode(), compareOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (compareOperator instanceof LtE or compareOperator instanceof Lt) and
        branchValue = false and
        compareNode.operands(_, compareOperator, lengthNode.asCfgNode())
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

  predicate isBarrier(DataFlow::Node barrierGuardNode) {
    // Size limit checks prevent uncontrolled input expansion
    barrierGuardNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkArgNode) {
    // Direct normalization calls
    exists(UnicodeCompatibilityNormalizationCall normCall |
      sinkArgNode = normCall.getTargetStringArg()
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