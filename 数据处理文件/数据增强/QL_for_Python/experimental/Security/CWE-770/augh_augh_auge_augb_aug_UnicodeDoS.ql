/**
 * @name Denial of Service via Unicode Character Processing
 * @description Detects remote user input processed by computationally expensive Unicode normalization 
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
// pyunormalize, and textnorm modules. normalizedArgPos identifies which argument 
// contains the string to be normalized.
class UnicodeNormalizationCall extends API::CallNode {
  int normalizedArgPos; // Position of argument being normalized

  UnicodeNormalizationCall() {
    // Case 1: normalize() calls with NFKC/NFKD form (2nd argument normalized)
    exists(string normForm |
      normForm in ["NFKC", "NFKD"] and
      (
        // unicodedata.normalize() calls
        (
          this = API::moduleImport("unicodedata").getMember("normalize").getACall() and
          this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normForm
        )
        or
        // pyunormalize.normalize() calls
        (
          this = API::moduleImport("pyunormalize").getMember("normalize").getACall() and
          this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normForm
        )
      ) and
      normalizedArgPos = 1
    )
    or
    // Case 2: Other normalization calls where 1st argument is normalized
    (
      // textnorm.normalize_unicode() calls
      (
        this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
        exists(string normForm |
          normForm in ["NFKC", "NFKD"] and
          this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() = normForm
        )
      )
      or
      // unidecode.unidecode() calls
      this = API::moduleImport("unidecode").getMember("unidecode").getACall()
      or
      // pyunormalize.NFKC() or pyunormalize.NFKD() calls
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    normalizedArgPos = 0
  }

  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(normalizedArgPos) 
  }
}

// Identifies guard conditions enforcing size limits on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branch) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenVal |
      lenCall = lenVal.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (branch true)
        (op instanceof LtE or op instanceof Lt) and
        branch = true and
        comparison.operands(lenVal.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (branch true)
        (op instanceof GtE or op instanceof Gt) and
        branch = true and
        comparison.operands(_, op, lenVal.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (branch false)
        (op instanceof GtE or op instanceof Gt) and
        branch = false and
        comparison.operands(lenVal.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (branch false)
        (op instanceof LtE or op instanceof Lt) and
        branch = false and
        comparison.operands(_, op, lenVal.asCfgNode())
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
    // Size limit checks prevent uncontrolled input growth
    barrier = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    exists(UnicodeNormalizationCall normCall |
      sink = normCall.getNormalizedArgument()
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