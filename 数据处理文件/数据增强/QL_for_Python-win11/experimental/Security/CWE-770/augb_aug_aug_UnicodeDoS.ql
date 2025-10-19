/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies when attacker-controlled input reaches expensive Unicode normalization operations (NFKC/NFKD). 
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

// Defines Unicode normalization function calls from unicodedata, unidecode, 
// pyunormalize, and textnorm modules that use compatibility forms (NFKC/NFKD)
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int argIndexToNormalize; // Index of the parameter containing the string to normalize

  UnicodeCompatibilityNormalizationCall() {
    // Scenario 1: normalize() calls with NFKC/NFKD form (2nd argument processed)
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
    argIndexToNormalize = 1
    or
    // Scenario 2: Other normalization calls where first argument is processed
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
    argIndexToNormalize = 0
  }

  DataFlow::Node getTargetArgument() { 
    result = this.getArg(argIndexToNormalize) 
  }
}

// Detects guard conditions enforcing size constraints on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchResult) {
  exists(CompareNode cmpNode | cmpNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop cmpOperator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Pattern: input <= LIMIT or input < LIMIT (true branch)
        (cmpOperator instanceof LtE or cmpOperator instanceof Lt) and
        branchResult = true and
        cmpNode.operands(lengthNode.asCfgNode(), cmpOperator, _)
        or
        // Pattern: LIMIT >= input or LIMIT > input (true branch)
        (cmpOperator instanceof GtE or cmpOperator instanceof Gt) and
        branchResult = true and
        cmpNode.operands(_, cmpOperator, lengthNode.asCfgNode())
        or
        // Pattern: not input >= LIMIT or not input > LIMIT (false branch)
        (cmpOperator instanceof GtE or cmpOperator instanceof Gt) and
        branchResult = false and
        cmpNode.operands(lengthNode.asCfgNode(), cmpOperator, _)
        or
        // Pattern: not LIMIT <= input or not LIMIT < input (false branch)
        (cmpOperator instanceof LtE or cmpOperator instanceof Lt) and
        branchResult = false and
        cmpNode.operands(_, cmpOperator, lengthNode.asCfgNode())
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

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size limit checks prevent uncontrolled input expansion
    barrierNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct Unicode normalization calls
    exists(UnicodeCompatibilityNormalizationCall unicodeNormCall |
      sinkNode = unicodeNormCall.getTargetArgument()
    )
    or
    // werkzeug's secure_filename() performs internal Unicode normalization
    exists(API::CallNode werkzeugSecureCall |
      (
        werkzeugSecureCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        werkzeugSecureCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
      ) and
      sinkNode = werkzeugSecureCall.getArg(_)
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