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
  int stringArgIndex; // Index of the argument holding the string to normalize

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
    stringArgIndex = 1
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
    stringArgIndex = 0
  }

  // Returns the argument node containing the string to normalize
  DataFlow::Node getNormalizedStringArg() { 
    result = this.getArg(stringArgIndex) 
  }
}

// Identifies guard conditions that enforce size restrictions on input values
predicate enforcesSizeLimit(DataFlow::GuardNode guardNode, ControlFlowNode controlledNode, boolean branchCondition) {
  exists(CompareNode compareNode | compareNode = guardNode |
    exists(API::CallNode lengthCall, Cmpop operator, Node lengthNode |
      lengthCall = lengthNode.getALocalSource() and
      (
        // Patterns: input <= LIMIT or input < LIMIT (true branch)
        (operator instanceof LtE or operator instanceof Lt) and
        branchCondition = true and
        compareNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: LIMIT >= input or LIMIT > input (true branch)
        (operator instanceof GtE or operator instanceof Gt) and
        branchCondition = true and
        compareNode.operands(_, operator, lengthNode.asCfgNode())
        or
        // Patterns: not input >= LIMIT or not input > LIMIT (false branch)
        (operator instanceof GtE or operator instanceof Gt) and
        branchCondition = false and
        compareNode.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Patterns: not LIMIT <= input or not LIMIT < input (false branch)
        (operator instanceof LtE or operator instanceof Lt) and
        branchCondition = false and
        compareNode.operands(_, operator, lengthNode.asCfgNode())
      )
    |
      lengthCall = API::builtin("len").getACall() and
      controlledNode = lengthCall.getArg(0).asCfgNode()
    )
  )
}

// Taint tracking configuration for Unicode DoS vulnerability detection
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrierNode) {
    // Size checks prevent uncontrolled input expansion
    barrierNode = DataFlow::BarrierGuard<enforcesSizeLimit/3>::getABarrierNode()
  }

  predicate isSink(DataFlow::Node sinkNode) {
    // Direct normalization calls
    exists(UnicodeCompatibilityNormalizationCall normalizationCall |
      sinkNode = normalizationCall.getNormalizedStringArg()
    )
    or
    // werkzeug's secure_filename() performs internal Unicode normalization
    exists(API::CallNode secureFilenameCall |
      (
        secureFilenameCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall()
        or
        secureFilenameCall = API::moduleImport("werkzeug")
                          .getMember("utils")
                          .getMember("secure_filename")
                          .getACall()
      ) and
      sinkNode = secureFilenameCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Unicode DoS configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

from UnicodeDoSFlow::PathNode pathSource, UnicodeDoSFlow::PathNode pathSink
where UnicodeDoSFlow::flowPath(pathSource, pathSink)
select pathSink.getNode(), pathSource, pathSink, "This $@ can reach a $@.", pathSource.getNode(),
  "user-provided value", pathSink.getNode(), "costly Unicode normalization operation"