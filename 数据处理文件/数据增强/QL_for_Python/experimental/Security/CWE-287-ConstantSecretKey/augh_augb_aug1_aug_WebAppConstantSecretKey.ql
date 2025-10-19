/**
 * @name Hardcoded SECRET_KEY in Flask/Django Applications
 * @description Detects constant values assigned to SECRET_KEY configuration
 * in Flask/Django applications, which may lead to authentication bypass
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

// Enumeration of supported web frameworks
newtype WebFramework =
  Flask() or
  Django()

// Configuration module for detecting hardcoded secret keys
private module SecretKeyDetectionConfig {
  import semmle.python.dataflow.new.DataFlow

  // Identify potential secret key sources (non-empty strings)
  predicate isPotentialSecretSource(DataFlow::Node secretSourceNode) {
    exists(string secretValue |
      secretValue = secretSourceNode.asExpr().(StringLiteral).getText() and
      secretValue.length() > 0 and
      // Exclude common placeholder values
      not secretValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY assignment targets
  predicate isSecretKeyAssignmentSink(DataFlow::Node secretKeySinkNode) {
    exists(DataFlow::Node secretKeyAttributeNode |
      secretKeyAttributeNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      secretKeySinkNode.asExpr() = secretKeyAttributeNode.asExpr().(Attribute).getObject()
    )
  }
}

// Data flow configuration with framework state tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state type
  class FlowState = WebFramework;

  // Barrier nodes to filter false positives
  predicate isBarrier(DataFlow::Node node) {
    // Standard library exclusions
    node.getLocation().getFile().inStdlib()
    or
    // Test/demo/example file exclusions
    exists(string relativePath |
      relativePath = node.getLocation().getFile().getRelativePath() and
      relativePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relativePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Non-secret literal exclusions
    exists(string literalText |
      literalText = node.asExpr().(StringLiteral).getText() and
      literalText in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Source identification for both frameworks
  predicate isSource(DataFlow::Node source, FlowState framework) {
    framework = Flask() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
    or
    framework = Django() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
  }

  // Sink identification for both frameworks
  predicate isSink(DataFlow::Node sink, FlowState framework) {
    framework = Flask() and SecretKeyDetectionConfig::isSecretKeyAssignmentSink(sink)
    or
    framework = Django() and SecretKeyDetectionConfig::isSecretKeyAssignmentSink(sink)
  }

  // Enable differential analysis in incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state
module WebAppSecretKeyFlow = TaintTracking::GlobalWithState<WebAppSecretKeyConfig>;

// Path graph for flow visualization
import WebAppSecretKeyFlow::PathGraph

// Query to detect hardcoded secret key assignments
from WebAppSecretKeyFlow::PathNode source, WebAppSecretKeyFlow::PathNode sink
where WebAppSecretKeyFlow::flowPath(source, sink)
select sink, source, sink, "The SECRET_KEY config variable is assigned by $@.", source,
  " this constant String"