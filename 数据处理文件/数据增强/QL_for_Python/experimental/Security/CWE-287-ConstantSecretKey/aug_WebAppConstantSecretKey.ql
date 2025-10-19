/**
 * @name Initializing SECRET_KEY of Flask application with Constant value
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

// Module for Flask constant secret key configuration
private module FlaskConstantSecretKeyConfig {
  import semmle.python.dataflow.new.DataFlow

  // Define sources for Flask constant secret key
  predicate isSource(DataFlow::Node source) {
    exists(string value |
      value = source.asExpr().(StringLiteral).getText() and
      value.length() > 0 and
      // Exclude obviously non-secret values like empty strings or common placeholders
      not value in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Define sinks for Flask constant secret key
  predicate isSink(DataFlow::Node sink) {
    exists(DataFlow::Node configNode |
      configNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sink.asExpr() = configNode.asExpr().(Attribute).getObject()
    )
  }
}

// Module for Django constant secret key configuration
private module DjangoConstantSecretKeyConfig {
  import semmle.python.dataflow.new.DataFlow

  // Define sources for Django constant secret key
  predicate isSource(DataFlow::Node source) {
    exists(string value |
      value = source.asExpr().(StringLiteral).getText() and
      value.length() > 0 and
      // Exclude obviously non-secret values like empty strings or common placeholders
      not value in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Define sinks for Django constant secret key
  predicate isSink(DataFlow::Node sink) {
    exists(DataFlow::Node configNode |
      configNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      sink.asExpr() = configNode.asExpr().(Attribute).getObject()
    )
  }
}

// Configuration for data flow analysis with framework state tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state type definition
  class FlowState = WebFramework;

  // Identify source nodes based on framework type
  predicate isSource(DataFlow::Node source, FlowState framework) {
    framework = Flask() and FlaskConstantSecretKeyConfig::isSource(source)
    or
    framework = Django() and DjangoConstantSecretKeyConfig::isSource(source)
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
    framework = Flask() and FlaskConstantSecretKeyConfig::isSink(sink)
    or
    framework = Django() and DjangoConstantSecretKeyConfig::isSink(sink)
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