/**
 * @name Denial of Service using Unicode Characters
 * @description Identifies code paths where user-supplied input reaches Unicode normalization
 *              operations (NFKC/NFKD) that could trigger denial of service. These operations
 *              may exponentially increase payload size (e.g., U+2100 ℀ triples in size during normalization).
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

// Identifies function calls that perform Unicode normalization using compatibility forms
// (specifically NFKC or NFKD). This class also tracks the argument position of the string
// that undergoes normalization.
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int argIndexForNormalizedString; // Position of the normalized string argument

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
    argIndexForNormalizedString = 1
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
    argIndexForNormalizedString = 0
  }

  // Retrieves the argument node containing the string to normalize
  DataFlow::Node getNormalizedStringArg() { 
    result = this.getArg(argIndexForNormalizedString) 
  }
}

// Identifies guard conditions that enforce size restrictions on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branch) {
  exists(CompareNode comparisonNode | comparisonNode = guard |
    exists(API::CallNode lengthFunctionCall, Cmpop operator, Node lengthValueNode |
      lengthFunctionCall = lengthValueNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (operator instanceof LtE or operator instanceof Lt) and
        branch = true and
        comparisonNode.operands(lengthValueNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (operator instanceof GtE or operator instanceof Gt) and
        branch = true and
        comparisonNode.operands(_, operator, lengthValueNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (operator instanceof GtE or operator instanceof Gt) and
        branch = false and
        comparisonNode.operands(lengthValueNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (operator instanceof LtE or operator instanceof Lt) and
        branch = false and
        comparisonNode.operands(_, operator, lengthValueNode.asCfgNode())
      )
    |
      lengthFunctionCall = API::builtin("len").getACall() and
      controlled = lengthFunctionCall.getArg(0).asCfgNode()
    )
  )
}

// Configuration for taint tracking analysis targeting Unicode Denial of Service vulnerabilities
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
    exists(UnicodeCompatibilityNormalizationCall normalizationCall |
      sink = normalizationCall.getNormalizedStringArg()
    )
    or
    // werkzeug's secure_filename() uses Unicode normalization internally
    exists(API::CallNode werkzeugFunctionCall |
      (
        werkzeugFunctionCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        werkzeugFunctionCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
      ) and
      sink = werkzeugFunctionCall.getArg(_)
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