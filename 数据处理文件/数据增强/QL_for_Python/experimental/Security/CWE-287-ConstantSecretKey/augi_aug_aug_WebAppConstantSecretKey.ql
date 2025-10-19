/**
 * @name Hardcoded SECRET_KEY in Web Applications
 * @description Static assignment of SECRET_KEY in Flask/Django applications
 * may enable authentication bypass attacks
 * @kind path-problem
 * @id py/webapp-hardcoded-secret
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

// Web framework classification for analysis
newtype WebFrameworkType =
  FlaskFramework() or
  DjangoFramework()

// Configuration module for secret key analysis with framework tracking
private module SecretKeyAnalysisConfig implements DataFlow::StateConfigSig {
  // Framework state representation
  class FlowState = WebFrameworkType;

  // Identify hardcoded string sources
  predicate isSource(DataFlow::Node sourceNode, FlowState frameworkType) {
    exists(string secretLiteral |
      secretLiteral = sourceNode.asExpr().(StringLiteral).getText() and
      secretLiteral.length() > 0 and
      // Filter non-secret placeholder values
      not secretLiteral.matches(["", "changeme", "secret", "password", "default"]) and
      (frameworkType = FlaskFramework() or frameworkType = DjangoFramework())
    )
  }

  // Identify secret key assignment sinks
  predicate isSink(DataFlow::Node sinkNode, FlowState frameworkType) {
    exists(DataFlow::Node secretKeyAttr |
      secretKeyAttr.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sinkNode.asExpr() = secretKeyAttr.asExpr().(Attribute).getObject() and
      (frameworkType = FlaskFramework() or frameworkType = DjangoFramework())
    )
  }

  // Define sanitization barriers
  predicate isBarrier(DataFlow::Node barrierNode) {
    // Exclude standard library components
    barrierNode.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo files except specific test cases
    exists(string filePathStr |
      filePathStr = barrierNode.getLocation().getFile().getRelativePath() and
      filePathStr.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not filePathStr.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Filter obvious non-secret values
    exists(string nonSecretLiteral |
      nonSecretLiteral = barrierNode.asExpr().(StringLiteral).getText() and
      nonSecretLiteral in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Enable differential analysis in incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state awareness
module SecretKeyTaintFlow = TaintTracking::GlobalWithState<SecretKeyAnalysisConfig>;

// Import path graph for vulnerability flow visualization
import SecretKeyTaintFlow::PathGraph

// Query to identify hardcoded secret key assignments
from SecretKeyTaintFlow::PathNode sourcePathNode, SecretKeyTaintFlow::PathNode sinkPathNode
where SecretKeyTaintFlow::flowPath(sourcePathNode, sinkPathNode)
select sinkPathNode, sourcePathNode, sinkPathNode, "SECRET_KEY assigned from $@.", sourcePathNode,
  " hardcoded value"