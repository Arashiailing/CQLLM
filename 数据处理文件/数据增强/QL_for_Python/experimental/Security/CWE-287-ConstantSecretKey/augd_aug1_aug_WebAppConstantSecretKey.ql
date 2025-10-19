/**
 * @name Initializing SECRET_KEY of Flask/Django with Constant Value
 * @description Detects hardcoded SECRET_KEY assignments in Flask/Django applications
 * which can enable authentication bypass vulnerabilities
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

// Framework type enumeration (Flask or Django)
newtype WebFramework =
  Flask() or
  Django()

// Centralized configuration for secret key detection logic
private module SecretKeyDetectionConfig {
  import semmle.python.dataflow.new.DataFlow

  // Identify potential secret key sources (non-empty strings excluding placeholders)
  predicate isPotentialSecretSource(DataFlow::Node potentialSecretSource) {
    exists(string strValue |
      strValue = potentialSecretSource.asExpr().(StringLiteral).getText() and
      strValue.length() > 0 and
      // Filter common placeholder values
      not strValue in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Identify SECRET_KEY assignment targets
  predicate isSecretKeyAssignmentSink(DataFlow::Node secretKeySink) {
    exists(DataFlow::Node configAttrNode |
      configAttrNode.asExpr().(Attribute).getName() = "SECRET_KEY" and
      secretKeySink.asExpr() = configAttrNode.asExpr().(Attribute).getObject()
    )
  }
}

// Data flow configuration with framework state tracking
private module WebAppSecretKeyConfig implements DataFlow::StateConfigSig {
  // Framework state representation
  class FlowState = WebFramework;

  // Unified source detection for both frameworks
  predicate isSource(DataFlow::Node sourceNode, FlowState frameworkType) {
    SecretKeyDetectionConfig::isPotentialSecretSource(sourceNode) and
    (frameworkType = Flask() or frameworkType = Django())
  }

  // Barrier conditions to filter false positives
  predicate isBarrier(DataFlow::Node barrierNode) {
    // Exclude standard library components
    barrierNode.getLocation().getFile().inStdlib()
    or
    // Exclude test/demo/example files except specific test cases
    exists(string relativePath |
      relativePath = barrierNode.getLocation().getFile().getRelativePath() and
      relativePath.matches(["%test%", "%demo%", "%example%", "%sample%"]) and
      not relativePath.matches("%query-tests/Security/CWE-287%")
    )
    or
    // Exclude obvious placeholder values
    exists(string value |
      value = barrierNode.asExpr().(StringLiteral).getText() and
      value in ["", "changeme", "secret", "password", "default"]
    )
  }

  // Unified sink detection for both frameworks
  predicate isSink(DataFlow::Node sinkNode, FlowState frameworkType) {
    SecretKeyDetectionConfig::isSecretKeyAssignmentSink(sinkNode) and
    (frameworkType = Flask() or frameworkType = Django())
  }

  // Enable differential analysis for incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking with framework state
module WebAppSecretKeyFlow = TaintTracking::GlobalWithState<WebAppSecretKeyConfig>;

// Import path graph for visualization
import WebAppSecretKeyFlow::PathGraph

// Main query detecting hardcoded secret key assignments
from WebAppSecretKeyFlow::PathNode source, WebAppSecretKeyFlow::PathNode sink
where WebAppSecretKeyFlow::flowPath(source, sink)
select sink, source, sink, "The SECRET_KEY config variable is assigned by $@.", source,
  " this constant String"