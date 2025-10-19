/**
 * @name Denial of Service using Unicode Characters
 * @description Detects when remote user-controlled input reaches costly Unicode normalization operations (NFKC/NFKD). On Windows, attacks like "One Million Unicode Characters" can cause denial of service. Special characters (e.g., U+2100 ℀, U+2105 ℅) can triple payload size during normalization.
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

// Identifies Unicode normalization calls using compatibility forms (NFKC/NFKD)
// Tracks the argument index being normalized (targetArgIndex)
class UnicodeCompatibilityNormalize extends API::CallNode {
  int targetArgIndex; // Index of the normalized argument

  UnicodeCompatibilityNormalize() {
    // Case 1: normalize() calls with explicit NFKC/NFKD parameter
    exists(string normForm |
      normForm in ["NFKC", "NFKD"] and
      (
        // unicodedata.normalize(normForm, input)
        this = API::moduleImport("unicodedata").getMember("normalize").getACall() and
        this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normForm
        or
        // pyunormalize.normalize(normForm, input)
        this = API::moduleImport("pyunormalize").getMember("normalize").getACall() and
        this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normForm
      ) and
      targetArgIndex = 1  // Input is at index 1
    )
    or
    // Case 2: Implicit NFKC/NFKD normalization calls
    (
      // textnorm.normalize_unicode(encoding, normForm, input)
      this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
      this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() in ["NFKC", "NFKD"]
      or
      // unidecode.unidecode(input) - internally uses NFKC
      this = API::moduleImport("unidecode").getMember("unidecode").getACall()
      or
      // pyunormalize.NFKC(input) / pyunormalize.NFKD(input)
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    targetArgIndex = 0  // Input is at index 0
  }

  // Returns the argument node being normalized
  DataFlow::Node getNormalizedArgument() { 
    result = this.getArg(targetArgIndex) 
  }
}

// Checks if a value is constrained by length validation guards
predicate isLengthConstrained(DataFlow::GuardNode guardNode, ControlFlowNode checkedNode, boolean branchCondition) {
  exists(CompareNode comparisonNode | comparisonNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop comparisonOp, Node valueNode |
      lengthCall = valueNode.getALocalSource() and
      (
        // Handles: input <= LIMIT or input < LIMIT
        (comparisonOp instanceof LtE or comparisonOp instanceof Lt) and
        branchCondition = true and
        comparisonNode.operands(valueNode.asCfgNode(), comparisonOp, _)
        or
        // Handles: LIMIT >= input or LIMIT > input
        (comparisonOp instanceof GtE or comparisonOp instanceof Gt) and
        branchCondition = true and
        comparisonNode.operands(_, comparisonOp, valueNode.asCfgNode())
        or
        // Handles: not (input >= LIMIT) or not (input > LIMIT)
        (comparisonOp instanceof GtE or comparisonOp instanceof Gt) and
        branchCondition = false and
        comparisonNode.operands(valueNode.asCfgNode(), comparisonOp, _)
        or
        // Handles: not (LIMIT <= input) or not (LIMIT < input)
        (comparisonOp instanceof LtE or comparisonOp instanceof Lt) and
        branchCondition = false and
        comparisonNode.operands(_, comparisonOp, valueNode.asCfgNode())
      )
    |
      // Ensures we're checking len(input) constraints
      lengthCall = API::builtin("len").getACall() and
      checkedNode = lengthCall.getArg(0).asCfgNode()
    )
  )
}

// Configuration for taint tracking analysis
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource  // Remote user input is the source
  }

  predicate isBarrier(DataFlow::Node sanitizer) {
    // Length validation guards act as sanitizers
    sanitizer = DataFlow::BarrierGuard<isLengthConstrained/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeCompatibilityNormalize ucn).getNormalizedArgument()
    or
    // werkzeug.utils.secure_filename() (uses NFKC internally)
    sink = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    sink =
      API::moduleImport("werkzeug")
          .getMember("utils")
          .getMember("secure_filename")
          .getACall()
          .getArg(_)
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module using our configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"