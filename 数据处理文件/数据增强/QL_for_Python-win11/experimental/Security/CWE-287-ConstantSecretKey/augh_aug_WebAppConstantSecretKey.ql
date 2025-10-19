/**
 * @name Hardcoded SECRET_KEY in Flask/Django Applications
 * @description Assigning constant values to SECRET_KEY in Flask/Django applications
 * can lead to authentication bypass vulnerabilities
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

// Web framework enumeration (Flask or Django)
newtype WebFrameworkType =
  FlaskFramework() or
  DjangoFramework()

// Shared configuration for secret key analysis
private module SecretKeyAnalysisConfig {
  import semmle.python.dataflow.new.DataFlow

  // Identify hardcoded string sources
  predicate isHardcodedStringSource(DataFlow::Node sourceNode) {
    exists(string stringValue |
      stringValue = sourceNode.asExpr().(StringLiteral).getText() and
      stringValue.length() > 0 and
      // Exclude non-secret placeholder values
      not stringValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY assignment targets
  predicate isSecretKeyAssignment(DataFlow::Node assignmentNode) {
    exists(DataFlow::Node secretKeyAttr |
      secretKeyAttr.asExpr().(Attribute).getName() = "SECRET_KEY" and
      assignmentNode.asExpr() = secretKeyAttr.asExpr().(Attribute).getObject()
    )
  }
}

// Data flow configuration with framework tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state representation
  class FlowState = WebFrameworkType;

  // Source identification based on framework
  predicate isSource(DataFlow::Node source, FlowState framework) {
    SecretKeyAnalysisConfig::isHardcodedStringSource(source) and
    (framework = FlaskFramework() or framework = DjangoFramework())
  }

  // Barrier definitions to filter false positives
  predicate isBarrier(DataFlow::Node node) {
    // Exclude standard library code
    node.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo files (except specific security tests)
    exists(string relativePath |
      relativePath = node.getLocation().getFile().getRelativePath() and
      relativePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relativePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Exclude known placeholder values
    exists(string placeholderValue |
      placeholderValue = node.asExpr().(StringLiteral).getText() and
      placeholderValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Sink identification based on framework
  predicate isSink(DataFlow::Node sink, FlowState framework) {
    SecretKeyAnalysisConfig::isSecretKeyAssignment(sink) and
    (framework = FlaskFramework() or framework = DjangoFramework())
  }

  // Enable differential analysis for incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state
module WebAppSecretKeyFlow = TaintTracking::GlobalWithState<WebAppSecretKeyConfig>;

// Import path graph for visualization
import WebAppSecretKeyFlow::PathGraph

// Main query detecting hardcoded secret key assignments
from WebAppSecretKeyFlow::PathNode sourceNode, WebAppSecretKeyFlow::PathNode sinkNode
where WebAppSecretKeyFlow::flowPath(sourceNode, sinkNode)
select sinkNode, sourceNode, sinkNode, "The SECRET_KEY config variable is assigned by $@.", sourceNode,
  " this constant String"