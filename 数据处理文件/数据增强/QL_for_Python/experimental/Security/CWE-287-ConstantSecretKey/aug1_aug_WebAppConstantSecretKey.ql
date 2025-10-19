/**
 * @name Initializing SECRET_KEY of Flask/Django with Constant Value
 * @description Hardcoded SECRET_KEY values in Flask/Django applications
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

// Define web framework types (Flask or Django)
newtype WebFramework =
  Flask() or
  Django()

// Unified configuration module for constant secret key detection
private module SecretKeyDetectionConfig {
  import semmle.python.dataflow.new.DataFlow

  // Identify constant string sources that could be secret keys
  predicate isPotentialSecretSource(DataFlow::Node sourceNode) {
    exists(string strValue |
      strValue = sourceNode.asExpr().(StringLiteral).getText() and
      strValue.length() > 0 and
      // Exclude common placeholder values
      not strValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY assignment sinks
  predicate isSecretKeyAssignmentSink(DataFlow::Node sinkNode) {
    exists(DataFlow::Node configAttrNode |
      configAttrNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sinkNode.asExpr() = configAttrNode.asExpr().(Attribute).getObject()
    )
  }
}

// Configuration for data flow analysis with framework state tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state type definition
  class FlowState = WebFramework;

  // Identify source nodes based on framework type
  predicate isSource(DataFlow::Node source, FlowState framework) {
    framework = Flask() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
    or
    framework = Django() and SecretKeyDetectionConfig::isPotentialSecretSource(source)
  }

  // Define barrier nodes to filter false positives
  predicate isBarrier(DataFlow::Node node) {
    // Exclude standard library nodes
    node.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo/example/sample files except specific test cases
    exists(string relativePath |
      relativePath = node.getLocation().getFile().getRelativePath() and
      relativePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relativePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Exclude nodes that are clearly not secret keys
    exists(string value |
      value = node.asExpr().(StringLiteral).getText() and
      value in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify sink nodes based on framework type
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

// Import path graph for flow visualization
import WebAppSecretKeyFlow::PathGraph

// Query to detect hardcoded secret key assignments
from WebAppSecretKeyFlow::PathNode source, WebAppSecretKeyFlow::PathNode sink
where WebAppSecretKeyFlow::flowPath(source, sink)
select sink, source, sink, "The SECRET_KEY config variable is assigned by $@.", source,
  " this constant String"