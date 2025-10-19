/**
 * @name Timing attack against secret
 * @description Detects verification routines that compare sensitive values without constant-time guarantees,
 *              enabling timing attacks to extract confidential data through response time variations.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration tracking data flow from sensitive sources to vulnerable comparison operations.
 */
private module SecretToComparisonFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sensitiveOrigin) { sensitiveOrigin instanceof SecretSource }
  predicate isSink(DataFlow::Node comparisonSink) { comparisonSink instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Taint tracking configuration for secret flows to unsafe comparisons
module SecretTokenToComparisonFlow = TaintTracking::Global<SecretToComparisonFlowConfig>;
import SecretTokenToComparisonFlow::PathGraph

// Query detecting timing attack vulnerabilities
from SecretTokenToComparisonFlow::PathNode sensitiveTokenSource, SecretTokenToComparisonFlow::PathNode vulnerableComparisonSink
where SecretTokenToComparisonFlow::flowPath(sensitiveTokenSource, vulnerableComparisonSink)
select vulnerableComparisonSink.getNode(), sensitiveTokenSource, vulnerableComparisonSink, "Timing attack against $@ validation.", sensitiveTokenSource.getNode(), "client-supplied token"