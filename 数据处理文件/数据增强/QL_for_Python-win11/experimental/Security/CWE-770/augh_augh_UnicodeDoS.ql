/**
 * @name Denial of Service using Unicode Characters
 * @description Identifies when untrusted remote input reaches resource-intensive Unicode normalization (NFKC/NFKD). 
 *              On Windows, attacks like "One Million Unicode Characters" can cause DoS. 
 *              Special Unicode chars (e.g., U+2100 ℀, U+2105 ℅) can triple payload size.
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

// Represents Unicode normalization calls with compatibility forms (NFKC/NFKD)
// normalizedArgIndex specifies which argument contains the string to normalize
class UnicodeNormalizationCall extends API::CallNode {
  int normalizedArgIndex; // Index of the argument being normalized

  UnicodeNormalizationCall() {
    // Handle unicodedata/pyunormalize.normalize calls with NFKC/NFKD
    exists(string normalizationForm | normalizationForm in ["NFKC", "NFKD"] |
      (
        this = API::moduleImport("unicodedata").getMember("normalize").getACall() or
        this = API::moduleImport("pyunormalize").getMember("normalize").getACall()
      ) and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() = normalizationForm and
      normalizedArgIndex = 1
    )
    or
    // Handle textnorm.normalize_unicode calls with NFKC/NFKD
    exists(string normalizationForm | normalizationForm in ["NFKC", "NFKD"] |
      this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
      this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() = normalizationForm and
      normalizedArgIndex = 0
    )
    or
    // Handle unidecode.unidecode and pyunormalize.NFKC/NFKD calls
    (
      this = API::moduleImport("unidecode").getMember("unidecode").getACall() or
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    normalizedArgIndex = 0
  }

  // Returns the argument node containing the string to normalize
  DataFlow::Node getTargetArgument() { result = this.getArg(normalizedArgIndex) }
}

// Checks if a value is constrained by length checks in control flow
predicate isLengthChecked(DataFlow::GuardNode guard, ControlFlowNode checkedValue, boolean isBranchTaken) {
  exists(CompareNode comparison | comparison = guard |
    exists(API::CallNode lenCall, Cmpop operator, Node lengthNode |
      lenCall = lengthNode.getALocalSource() and
      lenCall = API::builtin("len").getACall() and
      checkedValue = lenCall.getArg(0).asCfgNode() and
      (
        // Cases: length <= LIMIT or length < LIMIT (when branch is true)
        (operator instanceof LtE or operator instanceof Lt) and
        isBranchTaken = true and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases: LIMIT >= length or LIMIT > length (when branch is true)
        (operator instanceof GtE or operator instanceof Gt) and
        isBranchTaken = true and
        comparison.operands(_, operator, lengthNode.asCfgNode())
        or
        // Cases: NOT(length >= LIMIT) or NOT(length > LIMIT) (when branch is false)
        (operator instanceof GtE or operator instanceof Gt) and
        isBranchTaken = false and
        comparison.operands(lengthNode.asCfgNode(), operator, _)
        or
        // Cases: NOT(LIMIT <= length) or NOT(LIMIT < length) (when branch is false)
        (operator instanceof LtE or operator instanceof Lt) and
        isBranchTaken = false and
        comparison.operands(_, operator, lengthNode.asCfgNode())
      )
    )
  )
}

// Configuration for Unicode DoS data flow analysis
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  predicate isBarrier(DataFlow::Node barrier) { 
    // Length checks act as sanitization barriers
    barrier = DataFlow::BarrierGuard<isLengthChecked/3>::getABarrierNode() 
  }

  predicate isSink(DataFlow::Node sink) {
    // Direct Unicode normalization calls
    sink = any(UnicodeNormalizationCall call).getTargetArgument()
    or
    // werkzeug's secure_filename (uses Unicode normalization internally)
    exists(API::CallNode secureCall |
      secureCall = API::moduleImport("werkzeug").getMember("secure_filename").getACall() or
      secureCall = API::moduleImport("werkzeug").getMember("utils").getMember("secure_filename").getACall()
    |
      sink = secureCall.getArg(_)
    )
  }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using the configuration
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph

// Query to find paths from remote sources to Unicode normalization sinks
from UnicodeDoSFlow::PathNode sourcePath, UnicodeDoSFlow::PathNode sinkPath
where UnicodeDoSFlow::flowPath(sourcePath, sinkPath)
select sinkPath.getNode(), sourcePath, sinkPath, 
  "This $@ can reach a $@.", 
  sourcePath.getNode(), "user-provided value", 
  sinkPath.getNode(), "costly Unicode normalization operation"