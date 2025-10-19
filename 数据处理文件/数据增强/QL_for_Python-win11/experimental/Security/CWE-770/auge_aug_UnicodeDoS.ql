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

/**
 * Represents calls to Unicode compatibility normalization functions from 
 * unicodedata, unidecode, pyunormalize, and textnorm modules.
 * The normalizedArgPosition identifies which argument contains the string to normalize.
 */
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedArgPosition; // Position of the argument being normalized

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
    normalizedArgPosition = 1
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
    normalizedArgPosition = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizedArgPosition) 
  }
}

/**
 * Identifies guard conditions that enforce size limits on input values.
 * These guards can prevent uncontrolled input growth that could lead to DoS.
 */
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchValue) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop cmpOperator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (cmpOperator instanceof LtE or cmpOperator instanceof Lt) and
        branchValue = true and
        comparisonNode.operands(lengthNode.asCfgNode(), cmpOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (cmpOperator instanceof GtE or cmpOperator instanceof Gt) and
        branchValue = true and
        comparisonNode.operands(_, cmpOperator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (cmpOperator instanceof GtE or cmpOperator instanceof Gt) and
        branchValue = false and
        comparisonNode.operands(lengthNode.asCfgNode(), cmpOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (cmpOperator instanceof LtE or cmpOperator instanceof Lt) and
        branchValue = false and
        comparisonNode.operands(_, cmpOperator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlledNode = lengthCall.getArg(0).asCfgNode()
    )
  )
}

/**
 * Configuration for taint tracking analysis of Unicode DoS vulnerabilities.
 * Defines sources, barriers, and sinks for the analysis.
 */
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size limit checks prevent uncontrolled input growth
    barrierNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct Unicode normalization calls
    sinkNode = any(UnicodeCompatibilityNormalizationCall ucnCall).getNormalizedArgument()
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
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode sourcePath, UnicodeDoSFlow::PathNode sinkPath
where UnicodeDoSFlow::flowPath(sourcePath, sinkPath)
select sinkPath.getNode(), sourcePath, sinkPath, "This $@ can reach a $@.", sourcePath.getNode(),
  "user-provided value", sinkPath.getNode(), "costly Unicode normalization operation"