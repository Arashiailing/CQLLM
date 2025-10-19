/**
 * @name Denial of Service using Unicode Characters
 * @description Detects when user-controlled input reaches costly Unicode normalization (NFKC/NFKD). 
 *              On Windows, this can cause DoS via "One Million Unicode Characters" attack. 
 *              Special characters like U+2100 (℀) can triple payload size during normalization.
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

// Represents Unicode normalization calls that could cause DoS
class UnicodeCompatibilityNormalize extends API::CallNode {
  int normalizedArgIndex; // Index of argument being normalized

  UnicodeCompatibilityNormalize() {
    // Handle unicodedata.normalize() and pyunormalize.normalize() calls
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
    normalizedArgIndex = 1 // Normalization is second argument
    or
    // Handle textnorm.normalize_unicode(), unidecode.unidecode(), and direct pyunormalize calls
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
    normalizedArgIndex = 0 // Normalization is first argument
  }

  // Returns the node containing the normalized input
  DataFlow::Node getPathArg() { result = this.getArg(normalizedArgIndex) }
}

// Checks if a string length is constrained by a comparison
predicate isLengthConstrained(DataFlow::GuardNode guardNode, ControlFlowNode checkedNode, boolean branch) {
  exists(CompareNode comparison | comparison = guardNode |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Cases where length is considered limited: arg <= LIMIT or arg < LIMIT
        (operator instanceof LtE or operator instanceof Lt) and
        branch = true and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases where length is considered limited: LIMIT >= arg or LIMIT > arg
        (operator instanceof GtE or operator instanceof Gt) and
        branch = true and
        comparison.operands(_, operator, lengthNode.asCfgNode())
        or
        // Cases where length is NOT limited: not arg >= LIMIT or not arg > LIMIT
        (operator instanceof GtE or operator instanceof Gt) and
        branch = false and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases where length is NOT limited: not LIMIT <= arg or not LIMIT < arg
        (operator instanceof LtE or operator instanceof Lt) and
        branch = false and
        comparison.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      checkedNode = lengthCall.getArg(0).asCfgNode() // Ensure we're checking len() argument
    )
  )
}

// Configuration for Unicode DoS data flow analysis
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node taintSource) { 
    taintSource instanceof RemoteFlowSource // Sources are remote user inputs
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Barriers are length checks that constrain input size
    barrierNode = DataFlow::BarrierGuard<isLengthConstrained/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node taintSink) {
    // Sinks are Unicode normalization operations
    taintSink = any(UnicodeCompatibilityNormalize normalizeCall).getPathArg()
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

  predicate observeDiffInformedIncrementalMode() { any() } // Enable incremental analysis
}

// Global taint tracking using our configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink) // Find paths from source to sink
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"