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
class UnicodeNormalizationCall extends API::CallNode {
  int normalizedInputPosition; // Index of argument being normalized

  UnicodeNormalizationCall() {
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
    normalizedInputPosition = 1 // Normalization is second argument
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
    normalizedInputPosition = 0 // Normalization is first argument
  }

  // Returns the node containing the normalized input
  DataFlow::Node getPathArg() { result = this.getArg(normalizedInputPosition) }
}

// Checks if a string length is constrained by a comparison
predicate isLengthConstrained(DataFlow::GuardNode guard, ControlFlowNode checkedExpr, boolean branchCondition) {
  exists(CompareNode compareNode | compareNode = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Cases where length is considered limited: arg <= LIMIT or arg < LIMIT
        (op instanceof LtE or op instanceof Lt) and
        branchCondition = true and
        compareNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Cases where length is considered limited: LIMIT >= arg or LIMIT > arg
        (op instanceof GtE or op instanceof Gt) and
        branchCondition = true and
        compareNode.operands(_, op, lenNode.asCfgNode())
        or
        // Cases where length is NOT limited: not arg >= LIMIT or not arg > LIMIT
        (op instanceof GtE or op instanceof Gt) and
        branchCondition = false and
        compareNode.operands(lenNode.asCfgNode(), op, _)
        or
        // Cases where length is NOT limited: not LIMIT <= arg or not LIMIT < arg
        (op instanceof LtE or op instanceof Lt) and
        branchCondition = false and
        compareNode.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      checkedExpr = lenCall.getArg(0).asCfgNode() // Ensure we're checking len() argument
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
    sinkNode = any(UnicodeNormalizationCall normalizeCall).getPathArg()
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

from UnicodeDoSFlow::PathNode pathSource, UnicodeDoSFlow::PathNode pathSink
where UnicodeDoSFlow::flowPath(pathSource, pathSink) // Find paths from source to sink
select pathSink.getNode(), pathSource, pathSink, "This $@ can reach a $@.", pathSource.getNode(),
  "user-provided value", pathSink.getNode(), "costly Unicode normalization operation"