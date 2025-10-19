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

// Framework classification for web applications
newtype WebFrameworkType =
  FlaskFramework() or
  DjangoFramework()

// Configuration for secret key analysis with framework tracking
private module SecretKeyAnalysisConfig implements DataFlow::StateConfigSig {
  // Framework state representation
  class FlowState = WebFrameworkType;

  // Identify hardcoded string sources
  predicate isSource(DataFlow::Node sourceNode, FlowState framework) {
    exists(string literalText |
      literalText = sourceNode.asExpr().(StringLiteral).getText() and
      literalText.length() > 0 and
      // Filter non-secret placeholder values
      not literalText.matches(["", "changeme", "secret", "password", "default"]) and
      (framework = FlaskFramework() or framework = DjangoFramework())
    )
  }

  // Identify secret key assignment sinks
  predicate isSink(DataFlow::Node sinkNode, FlowState framework) {
    exists(DataFlow::Node configAttr |
      configAttr.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sinkNode.asExpr() = configAttr.asExpr().(Attribute).getObject() and
      (framework = FlaskFramework() or framework = DjangoFramework())
    )
  }

  // Define sanitization barriers
  predicate isBarrier(DataFlow::Node node) {
    // Exclude standard library components
    node.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo files except specific test cases
    exists(string filePath |
      filePath = node.getLocation().getFile().getRelativePath() and
      filePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not filePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Filter obvious non-secret values
    exists(string literalVal |
      literalVal = node.asExpr().(StringLiteral).getText() and
      literalVal in ["", "changeme", "secret", "password", "default"]
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
from SecretKeyTaintFlow::PathNode origin, SecretKeyTaintFlow::PathNode destination
where SecretKeyTaintFlow::flowPath(origin, destination)
select destination, origin, destination, "SECRET_KEY assigned from $@.", origin,
  " hardcoded value"