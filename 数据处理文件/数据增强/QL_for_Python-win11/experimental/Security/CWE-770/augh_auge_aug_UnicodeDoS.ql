/**
 * @name Denial of Service via Unicode Normalization
 * @description Identifies when external user input reaches computationally expensive Unicode 
 *              normalization operations (NFKC/NFKD). These operations can trigger DoS 
 *              vulnerabilities on Windows through attacks like "One Million Unicode Characters", 
 *              where special characters (e.g., U+2100 ℀ or U+2105 ℅) can triple payload sizes.
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
 * The argumentPositionToNormalize identifies which argument contains the string to normalize.
 */
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int argumentPositionToNormalize; // Position of the argument being normalized

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
    argumentPositionToNormalize = 1
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
    argumentPositionToNormalize = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(argumentPositionToNormalize) 
  }
}

/**
 * Identifies guard conditions that enforce size limits on input values.
 * These guards prevent uncontrolled input growth that could lead to DoS.
 */
predicate hasSizeLimitGuard(DataFlow::GuardNode guardCondition, ControlFlowNode controlledElement, boolean branchTaken) {
  exists(CompareNode compareNode | compareNode = guardCondition |
    exists(API::CallNode lengthFunctionCall, Cmpop comparisonOperator, Node lengthValueNode |
      lengthFunctionCall = lengthValueNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchTaken = true and
        compareNode.operands(lengthValueNode.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchTaken = true and
        compareNode.operands(_, comparisonOperator, lengthValueNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchTaken = false and
        compareNode.operands(lengthValueNode.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchTaken = false and
        compareNode.operands(_, comparisonOperator, lengthValueNode.asCfgNode())
      )
    |
      lengthFunctionCall = API::builtin("len").getACall() and
      controlledElement = lengthFunctionCall.getArg(0).asCfgNode()
    )
  )
}

/**
 * Taint tracking configuration for Unicode DoS vulnerability analysis.
 * Defines sources (remote inputs), barriers (size checks), and sinks (normalization operations).
 */
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node taintSource) { 
    taintSource instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node taintBarrier) {
    // Size limit checks prevent uncontrolled input growth
    taintBarrier = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node taintSink) {
    // Direct Unicode normalization calls
    taintSink = any(UnicodeCompatibilityNormalizationCall ucnCall).getNormalizedArgument()
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    taintSink = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    taintSink =
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