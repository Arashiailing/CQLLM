/**
 * @name Hardcoded SECRET_KEY in Web Applications
 * @description Detects static assignment of SECRET_KEY in Flask/Django apps,
 *              which may enable authentication bypass attacks
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

// Framework types for web application classification
newtype WebFrameworkType =
  FlaskFramework() or
  DjangoFramework()

// Configuration module for secret key taint analysis with framework tracking
private module SecretKeyTaintConfig implements DataFlow::StateConfigSig {
  // State representation for web frameworks
  class FlowState = WebFrameworkType;

  // Identifies hardcoded string sources as potential secrets
  predicate isSource(DataFlow::Node sourceNode, FlowState framework) {
    exists(string secretLiteral |
      secretLiteral = sourceNode.asExpr().(StringLiteral).getText() and
      secretLiteral.length() > 0 and
      // Exclude common placeholder values
      not secretLiteral.matches(["", "changeme", "secret", "password", "default"]) and
      (framework = FlaskFramework() or framework = DjangoFramework())
    )
  }

  // Identifies secret key assignment targets
  predicate isSink(DataFlow::Node sinkNode, FlowState framework) {
    exists(DataFlow::Node secretKeyAttr |
      secretKeyAttr.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sinkNode.asExpr() = secretKeyAttr.asExpr().(Attribute).getObject() and
      (framework = FlaskFramework() or framework = DjangoFramework())
    )
  }

  // Defines sanitization barriers for taint analysis
  predicate isBarrier(DataFlow::Node node) {
    // Exclude standard library components
    node.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo files except specific test cases
    exists(string relativePath |
      relativePath = node.getLocation().getFile().getRelativePath() and
      relativePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relativePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Filter obvious non-secret values
    exists(string nonSecretLiteral |
      nonSecretLiteral = node.asExpr().(StringLiteral).getText() and
      nonSecretLiteral in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Enable differential analysis for incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state support
module SecretKeyFlowAnalysis = TaintTracking::GlobalWithState<SecretKeyTaintConfig>;

// Import path graph for vulnerability visualization
import SecretKeyFlowAnalysis::PathGraph

// Query to detect hardcoded secret key assignments
from SecretKeyFlowAnalysis::PathNode sourceNode, SecretKeyFlowAnalysis::PathNode sinkNode
where SecretKeyFlowAnalysis::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "SECRET_KEY assigned from $@.", sourceNode,
  " hardcoded value"