/**
 * @name Timing attack against secret
 * @description Identifies verification routines that compare secret values without constant-time guarantees,
 *              potentially enabling timing attacks to extract sensitive information through response time differences.
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
 * Configuration tracking data flow from sensitive tokens to vulnerable comparison operations.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node secretOrigin) { secretOrigin instanceof SecretSource }
  predicate isSink(DataFlow::Node comparisonTarget) { comparisonTarget instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Taint tracking configuration for secret flows to unsafe comparisons
module TokenToComparisonFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import TokenToComparisonFlow::PathGraph

// Query detecting timing attack vulnerabilities
from TokenToComparisonFlow::PathNode tokenSource, TokenToComparisonFlow::PathNode vulnerableComparison
where TokenToComparisonFlow::flowPath(tokenSource, vulnerableComparison)
select vulnerableComparison.getNode(), tokenSource, vulnerableComparison, "Timing attack against $@ validation.", tokenSource.getNode(), "client-supplied token"