/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies remote input processed by computationally expensive Unicode normalization 
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
// pyunormalize, and textnorm modules. argPositionOfNormalizedString identifies which argument 
// contains the string to be normalized.
class UnicodeNormalizationCall extends API::CallNode {
  int argPositionOfNormalizedString; // Position of argument being normalized

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
      argPositionOfNormalizedString = 1
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
    argPositionOfNormalizedString = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(argPositionOfNormalizedString) 
  }
}

// Identifies guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchCondition) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lenInvocation, Cmpop comparisonOperator, Node lenValue |
      lenInvocation = lenValue.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchCondition = true and
        comparisonNode.operands(lenValue.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchCondition = true and
        comparisonNode.operands(_, comparisonOperator, lenValue.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (comparisonOperator instanceof GtE or comparisonOperator instanceof Gt) and
        branchCondition = false and
        comparisonNode.operands(lenValue.asCfgNode(), comparisonOperator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (comparisonOperator instanceof LtE or comparisonOperator instanceof Lt) and
        branchCondition = false and
        comparisonNode.operands(_, comparisonOperator, lenValue.asCfgNode())
      )
    |
      lenInvocation = API::builtin("len").getACall() and
      controlledNode = lenInvocation.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
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
    exists(UnicodeNormalizationCall normalizationCall |
      sinkNode = normalizationCall.getNormalizedArgument()
    )
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    exists(API::CallNode werkzeugInvocation |
      (
        werkzeugInvocation = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        werkzeugInvocation = API::moduleImport("werkzeug")
                            .getMember("utils")
                            .getMember("secure_filename")
                            .getACall()
      ) and
      sinkNode = werkzeugInvocation.getArg(_)
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