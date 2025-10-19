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

// Web framework enumeration (Flask or Django)
newtype WebFramework =
  Flask() or
  Django()

// Configuration module for secret key detection
private module SecretKeyDetectionConfig {
  import semmle.python.dataflow.new.DataFlow

  // Identify potential secret key sources (non-empty strings)
  predicate isPotentialSecretSource(DataFlow::Node potentialSecretSourceNode) {
    exists(string secretValue |
      secretValue = potentialSecretSourceNode.asExpr().(StringLiteral).getText() and
      secretValue.length() > 0 and
      // Exclude common placeholder values
      not secretValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY assignment targets
  predicate isSecretKeyAssignmentSink(DataFlow::Node secretKeyAssignmentSinkNode) {
    exists(DataFlow::Node secretKeyAttrNode |
      secretKeyAttrNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      secretKeyAssignmentSinkNode.asExpr() = secretKeyAttrNode.asExpr().(Attribute).getObject()
    )
  }
}

// Data flow configuration with framework state tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state type
  class FlowState = WebFramework;

  // Source identification for both frameworks
  predicate isSource(DataFlow::Node source, FlowState framework) {
    framework = Flask() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
    or
    framework = Django() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
  }

  // Barrier nodes to filter false positives
  predicate isBarrier(DataFlow::Node node) {
    // Standard library exclusions
    node.getLocation().getFile().inStdlib()
    or
    // Test/demo/example file exclusions
    exists(string filePath |
      filePath = node.getLocation().getFile().getRelativePath() and
      filePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not filePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Non-secret literal exclusions
    exists(string literalValue |
      literalValue = node.asExpr().(StringLiteral).getText() and
      literalValue in ["", "changeme", "secret", "password", "default"]
    )
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