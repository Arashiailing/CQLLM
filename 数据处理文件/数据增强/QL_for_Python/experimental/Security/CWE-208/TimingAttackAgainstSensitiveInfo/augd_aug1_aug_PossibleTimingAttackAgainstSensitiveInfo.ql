/**
 * @name Timing attack against secret
 * @description Detects verification functions that perform non-constant-time comparisons 
 *              of secret values, which could allow timing attacks to extract sensitive data.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import required modules
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking data flow from confidential sources 
 * to vulnerable comparison operations.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node origin) { origin instanceof SecretSource }
  predicate isSink(DataFlow::Node target) { target instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish taint tracking configuration and path graph
module SecretDataFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import SecretDataFlow::PathGraph

// Identify timing attack vulnerabilities through data flow paths
from SecretDataFlow::PathNode origin, SecretDataFlow::PathNode target
where SecretDataFlow::flowPath(origin, target)
select target.getNode(), origin, target, "Timing attack against $@ validation.", origin.getNode(), "client-supplied token"