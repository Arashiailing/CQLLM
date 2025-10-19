/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies remote user input processed by computationally expensive Unicode normalization 
 *              (NFKC/NFKD). These operations can cause DoS through attacks like "One Million Unicode Characters".
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) may triple payload size during normalization.
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

// Represents calls to Unicode normalization functions from unicodedata, unidecode, 
// pyunormalize, and textnorm modules. normalizationArgIndex identifies which argument 
// contains the string to be normalized.
class UnicodeNormalizationCall extends API::CallNode {
  int normalizationArgIndex; // Index of argument being normalized

  UnicodeNormalizationCall() {
    // Case 1: normalize() calls with NFKC/NFKD form (2nd argument normalized)
    exists(string normalizationForm |
      normalizationForm in ["NFKC", "NFKD"] and
      (
        // unicodedata.normalize() calls
        (
          this = API::moduleImport("unicodedata").getMember("normalize").getACall() and
          this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normalizationForm
        )
        or
        // pyunormalize.normalize() calls
        (
          this = API::moduleImport("pyunormalize").getMember("normalize").getACall() and
          this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normalizationForm
        )
      ) and
      normalizationArgIndex = 1
    )
    or
    // Case 2: Other normalization calls where 1st argument is normalized
    (
      // textnorm.normalize_unicode() calls
      (
        this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
        exists(string normalizationForm |
          normalizationForm in ["NFKC", "NFKD"] and
          this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() = normalizationForm
        )
      )
      or
      // unidecode.unidecode() calls
      this = API::moduleImport("unidecode").getMember("unidecode").getACall()
      or
      // pyunormalize.NFKC() or pyunormalize.NFKD() calls
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    normalizationArgIndex = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizationArgIndex) 
  }
}

// Identifies guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchValue) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lengthFunctionCall, Cmpop comparisonOperator, Node lengthValueNode |
      lengthFunctionCall = lengthValueNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchValue = true and
        comparisonNode.operands(lengthValueNode.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchValue = true and
        comparisonNode.operands(_, comparisonOperator, lengthValueNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchValue = false and
        comparisonNode.operands(lengthValueNode.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchValue = false and
        comparisonNode.operands(_, comparisonOperator, lengthValueNode.asCfgNode())
      )
    |
      lengthFunctionCall = API::builtin("len").getACall() and
      controlledNode = lengthFunctionCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
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
    exists(UnicodeNormalizationCall normalizationCall |
      sink = normalizationCall.getNormalizedArgument()
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

// Global taint tracking using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode sourceNode, UnicodeDoSFlow::PathNode sinkNode
where UnicodeDoSFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "This $@ can reach a $@.", sourceNode.getNode(),
  "user-provided value", sinkNode.getNode(), "costly Unicode normalization operation"