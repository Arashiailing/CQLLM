/**
 * @name Timing attack against secret
 * @description Identifies non-constant-time verification routines for secret values,
 *              potentially enabling timing attacks that expose sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import core Python language analysis modules
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint propagation capabilities
import semmle.python.dataflow.new.TaintTracking
// Import experimental timing attack detection utilities
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking data flow from secret origins to non-constant-time comparisons.
 * This setup identifies potential timing attack vulnerabilities in code.
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { any() }

  // Define origins: nodes representing secret sources
  predicate isSource(DataFlow::Node sourceNode) { sourceNode instanceof SecretSource }

  // Define targets: nodes representing non-constant-time comparison operations
  predicate isSink(DataFlow::Node sinkNode) { sinkNode instanceof NonConstantTimeComparisonSink }
}

// Establish global taint tracking using the timing attack configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;

// Import path visualization module for flow paths
import TimingAttackFlow::PathGraph

// Primary query to detect timing attack vulnerabilities
from
  TimingAttackFlow::PathNode secretSourceNode,  // Origin of the secret data
  TimingAttackFlow::PathNode comparisonSinkNode // Target comparison operation
where 
  // Verify existence of flow path from secret origin to comparison target
  TimingAttackFlow::flowPath(secretSourceNode, comparisonSinkNode)
select 
  comparisonSinkNode.getNode(),      // Location where vulnerability manifests
  secretSourceNode,                  // Origin of the flow
  comparisonSinkNode,                // Termination point of the flow
  "Timing attack against $@ verification.", // Security alert
  secretSourceNode.getNode(),        // Reference point for alert
  "client-provided secret"           // Description of the sensitive source