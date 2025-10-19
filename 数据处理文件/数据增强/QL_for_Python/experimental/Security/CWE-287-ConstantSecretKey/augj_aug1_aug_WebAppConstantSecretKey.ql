/**
 * @name Hardcoded SECRET_KEY in Flask/Django Applications
 * @description Storing hardcoded SECRET_KEY values in Flask/Django configurations
 * may enable authentication bypass attacks
 * @kind path-problem
 * @id py/flask-constant-secret-key
 * @problem.severity error
 * @security-severity 8.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import semmle.python.filters.Tests

// Framework classification (Flask or Django)
newtype WebFramework =
  FlaskFramework() or
  DjangoFramework()

// Centralized detection logic for secret key constants
private module SecretKeyAnalysis {
  import semmle.python.dataflow.new.DataFlow

  // Detect potential constant string sources for secret keys
  predicate isConstantSource(DataFlow::Node srcNode) {
    exists(string constVal |
      constVal = srcNode.asExpr().(StringLiteral).getText() and
      constVal.length() > 0 and
      // Filter common placeholder values
      not constVal in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY configuration assignments
  predicate isSecretKeySink(DataFlow::Node tgtNode) {
    exists(DataFlow::Node attrNode |
      attrNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      tgtNode.asExpr() = attrNode.asExpr().(Attribute).getObject()
    )
  }
}

// Data flow configuration with framework state tracking
private module SecretFlowConfig implements DataFlow::StateConfigSig {
  // Framework state representation
  class FlowState = WebFramework;

  // Source identification across frameworks
  predicate isSource(DataFlow::Node src, FlowState fw) {
    (fw = FlaskFramework() or fw = DjangoFramework()) and
    SecretKeyAnalysis::isConstantSource(src)
  }

  // Barrier definitions for false positive reduction
  predicate isBarrier(DataFlow::Node nd) {
    // Exclude standard library components
    nd.getLocation().getFile().inStdlib()
    or
    // Filter test/demo files except specific test cases
    exists(string relPath |
      relPath = nd.getLocation().getFile().getRelativePath() and
      relPath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relPath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Exclude non-secret placeholder values
    exists(string val |
      val = nd.asExpr().(StringLiteral).getText() and
      val in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Sink identification across frameworks
  predicate isSink(DataFlow::Node sk, FlowState fw) {
    (fw = FlaskFramework() or fw = DjangoFramework()) and
    SecretKeyAnalysis::isSecretKeySink(sk)
  }

  // Enable differential analysis in incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state
module SecretKeyFlow = TaintTracking::GlobalWithState<SecretFlowConfig>;

// Path graph import for visualization
import SecretKeyFlow::PathGraph

// Query for detecting hardcoded secret key assignments
from SecretKeyFlow::PathNode source, SecretKeyFlow::PathNode sink
where SecretKeyFlow::flowPath(source, sink)
select sink, source, sink, "The SECRET_KEY configuration is assigned using $@.", source,
  " this hardcoded value"