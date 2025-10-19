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
  int argIndexForNormalization; // Index of argument being normalized

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
    argIndexForNormalization = 1 // Normalization is second argument
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
    argIndexForNormalization = 0 // Normalization is first argument
  }

  // Returns the node containing the normalized input
  DataFlow::Node getPathArg() { result = this.getArg(argIndexForNormalization) }
}

// Checks if a string length is constrained by a comparison
predicate isLengthConstrained(DataFlow::GuardNode guard, ControlFlowNode nodeToCheck, boolean branchTaken) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Cases where length is considered limited: arg <= LIMIT or arg < LIMIT
        (operator instanceof LtE or operator instanceof Lt) and
        branchTaken = true and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases where length is considered limited: LIMIT >= arg or LIMIT > arg
        (operator instanceof GtE or operator instanceof Gt) and
        branchTaken = true and
        comparison.operands(_, operator, lengthNode.asCfgNode())
        or
        // Cases where length is NOT limited: not arg >= LIMIT or not arg > LIMIT
        (operator instanceof GtE or operator instanceof Gt) and
        branchTaken = false and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases where length is NOT limited: not LIMIT <= arg or not LIMIT < arg
        (operator instanceof LtE or operator instanceof Lt) and
        branchTaken = false and
        comparison.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      nodeToCheck = lengthCall.getArg(0).asCfgNode() // Ensure we're checking len() argument
    )
  )
}

// Configuration for Unicode DoS data flow analysis
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource // Sources are remote user inputs
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Barriers are length checks that constrain input size
    barrier = DataFlow::BarrierGuard<isLengthConstrained/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Sinks are Unicode normalization operations
    sinkNode = any(UnicodeCompatibilityNormalize normalizeCall).getPathArg()
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

  predicate observeDiffInformedIncrementalMode() { any() } // Enable incremental analysis
}

// Global taint tracking using our configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink) // Find paths from source to sink
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"