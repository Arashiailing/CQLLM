/**
 * @name Denial of Service using Unicode Characters
 * @description Identifies user-controlled inputs reaching costly Unicode normalization (NFKC/NFKD). 
 *              On Windows, this enables DoS via "One Million Unicode Characters" attack. 
 *              Characters like U+2100 (℀) can triple payload size during normalization.
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

// Represents Unicode normalization calls vulnerable to DoS attacks
class UnicodeCompatibilityNormalize extends API::CallNode {
  int inputArgIndex; // Index of the string input being normalized

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
    inputArgIndex = 1 // String input is second argument
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
    inputArgIndex = 0 // String input is first argument
  }

  // Returns the node containing the normalized input string
  DataFlow::Node getNormalizedInput() { result = this.getArg(inputArgIndex) }
}

// Determines if a string length is constrained by comparison operations
predicate isLengthConstrained(DataFlow::GuardNode guardNode, ControlFlowNode checkedNode, boolean branch) {
  exists(CompareNode comparison | comparison = guardNode |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Length constrained cases: arg <= LIMIT or arg < LIMIT
        (operator instanceof LtE or operator instanceof Lt) and
        branch = true and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Length constrained cases: LIMIT >= arg or LIMIT > arg
        (operator instanceof GtE or operator instanceof Gt) and
        branch = true and
        comparison.operands(_, operator, lengthNode.asCfgNode())
        or
        // Length unconstrained cases: not arg >= LIMIT or not arg > LIMIT
        (operator instanceof GtE or operator instanceof Gt) and
        branch = false and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Length unconstrained cases: not LIMIT <= arg or not LIMIT < arg
        (operator instanceof LtE or operator instanceof Lt) and
        branch = false and
        comparison.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      checkedNode = lengthCall.getArg(0).asCfgNode() // Verify we're checking len() argument
    )
  )
}

// Configuration for Unicode DoS vulnerability detection
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node taintedInput) { 
    taintedInput instanceof RemoteFlowSource // Sources are remote user inputs
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Barriers are length checks limiting input size
    barrierNode = DataFlow::BarrierGuard<isLengthConstrained/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node vulnerableSink) {
    // Sinks are Unicode normalization operations
    vulnerableSink = any(UnicodeCompatibilityNormalize normalizeCall).getNormalizedInput()
    or
    // werkzeug's secure_filename() internally uses Unicode normalization
    vulnerableSink = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    vulnerableSink =
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
where UnicodeDoSFlow::flowPath(source, sink) // Identify paths from source to sink
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"