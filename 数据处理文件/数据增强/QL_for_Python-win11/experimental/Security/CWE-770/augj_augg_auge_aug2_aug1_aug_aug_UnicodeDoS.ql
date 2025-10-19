/**
 * @name Denial of Service via Unicode Character Expansion
 * @description Detects data flows where user-controlled input reaches Unicode normalization
 *              operations (NFKC/NFKD) that may cause denial of service. These operations can
 *              exponentially expand input size (e.g., U+2100 ℀ becomes 3x larger during normalization).
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

// Identifies Unicode normalization calls that process compatibility characters
// (NFKC/NFKD forms) and tracks which argument contains the string to normalize
class UnicodeCompatibilityNormalizationCall extends API::CallNode {
  int normalizedStringArgIndex; // Index of the argument holding the string to normalize

  UnicodeCompatibilityNormalizationCall() {
    // Scenario 1: normalize() with explicit NFKC/NFKD form (2nd arg normalized)
    (
      this = API::moduleImport("unicodedata").getMember("normalize").getACall()
      or
      this = API::moduleImport("pyunormalize").getMember("normalize").getACall()
    ) and
    this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
        "NFKC", "NFKD"
      ] and
    normalizedStringArgIndex = 1
    or
    // Scenario 2: Direct normalization calls (1st arg normalized)
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
    normalizedStringArgIndex = 0
  }

  // Returns the argument node containing the string to normalize
  DataFlow::Node getNormalizedStringArg() { 
    result = this.getArg(normalizedStringArgIndex) 
  }
}

// Identifies guard conditions that enforce size restrictions on input values
predicate enforcesSizeLimit(DataFlow::GuardNode guard, ControlFlowNode controlled, boolean branch) {
  exists(CompareNode compare | compare = guard |
    exists(API::CallNode lenCall, Cmpop op, Node lenNode |
      lenCall = lenNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (op instanceof LtE or op instanceof Lt) and
        branch = true and
        compare.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (op instanceof GtE or op instanceof Gt) and
        branch = true and
        compare.operands(_, op, lenNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (op instanceof GtE or op instanceof Gt) and
        branch = false and
        compare.operands(lenNode.asCfgNode(), op, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (op instanceof LtE or op instanceof Lt) and
        branch = false and
        compare.operands(_, op, lenNode.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      controlled = lenCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability detection
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Size checks prevent uncontrolled input expansion
    barrier = DataFlow::BarrierGuard<enforcesSizeLimit/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct normalization calls
    exists(UnicodeCompatibilityNormalizationCall normCall |
      sink = normCall.getNormalizedStringArg()
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
      sink = secureCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode sourceNode, UnicodeDoSFlow::PathNode sinkNode
where UnicodeDoSFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "This $@ can reach a $@.", sourceNode.getNode(),
  "user-provided value", sinkNode.getNode(), "costly Unicode normalization operation"