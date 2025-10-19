/**
 * @name Denial of Service via Unicode Character Processing
 * @description Identifies attacker-controlled inputs reaching expensive Unicode normalization operations (NFKC/NFKD). 
 *              These operations can trigger denial of service through attacks like "One Million Unicode Characters". 
 *              Special characters (e.g., U+2100 ℀ or U+2105 ℅) can triple payload size during normalization.
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

// Detects Unicode normalization function calls using compatibility forms (NFKC/NFKD)
// from unicodedata, unidecode, pyunormalize, and textnorm modules
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int inputArgIndex; // Index of the parameter containing the string to normalize

  UnicodeCompatibilityNormalizationCall() {
    // Handles normalize() calls with NFKC/NFKD form (2nd argument processed)
    (
      (
        this = API::moduleImport("unicodedata").getMember("normalize").getACall()
        or
        this = API::moduleImport("pyunormalize").getMember("normalize").getACall()
      ) and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ] and
      inputArgIndex = 1
    )
    or
    // Handles other normalization calls where first argument is processed
    (
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
      inputArgIndex = 0
    )
  }

  DataFlow::Node getTargetArgument() { 
    result = this.getArg(inputArgIndex) 
  }
}

// Identifies guard conditions enforcing size constraints on input values
predicate hasSizeLimitGuard(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branch) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenValue |
      lenCall = lenValue.getALocalSource() and
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode() and
      (
        // True branch patterns: input <= LIMIT or input < LIMIT
        (op instanceof LtE or op instanceof Lt) and
        branch = true and
        comparison.operands(lenValue.asCfgNode(), op, _)
        or
        // True branch patterns: LIMIT >= input or LIMIT > input
        (op instanceof GtE or op instanceof Gt) and
        branch = true and
        comparison.operands(_, op, lenValue.asCfgNode())
        or
        // False branch patterns: not input >= LIMIT or not input > LIMIT
        (op instanceof GtE or op instanceof Gt) and
        branch = false and
        comparison.operands(lenValue.asCfgNode(), op, _)
        or
        // False branch patterns: not LIMIT <= input or not LIMIT < input
        (op instanceof LtE or op instanceof Lt) and
        branch = false and
        comparison.operands(_, op, lenValue.asCfgNode())
      )
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability analysis
private module UnicodeDoSAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size limit checks prevent uncontrolled input expansion
    barrierNode = DataFlow::BarrierGuard<hasSizeLimitGuard/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct Unicode normalization calls
    exists(UnicodeCompatibilityNormalizationCall normCall |
      sinkNode = normCall.getTargetArgument()
    )
    or
    // werkzeug's secure_filename() performs internal Unicode normalization
    exists(API::CallNode secureCall |
      (
        secureCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        secureCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
      ) and
      sinkNode = secureCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSAnalysisConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink
where UnicodeDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation"