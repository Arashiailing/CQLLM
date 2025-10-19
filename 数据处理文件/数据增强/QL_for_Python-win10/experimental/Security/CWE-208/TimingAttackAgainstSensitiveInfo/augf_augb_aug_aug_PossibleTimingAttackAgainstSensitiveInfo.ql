/**
 * @name Timing attack against secret
 * @description Identifies non-constant-time verification routines for secret values,
 *              which could enable timing attacks exposing sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Core Python language analysis imports
import python
// Data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Taint propagation capabilities
import semmle.python.dataflow.new.TaintTracking
// Experimental timing attack detection utilities
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking data flow from secret origins to non-constant-time comparisons.
 * This setup identifies potential timing attack vulnerabilities in code.
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // Define sources: nodes representing secret origins
  predicate isSource(DataFlow::Node secretSource) { 
    secretSource instanceof SecretSource 
  }

  // Define sinks: nodes representing non-constant-time comparison operations
  predicate isSink(DataFlow::Node nonConstantTimeComparisonSink) { 
    nonConstantTimeComparisonSink instanceof NonConstantTimeComparisonSink 
  }

  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Establish global taint tracking using the timing attack configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;

// Import path visualization module for flow paths
import TimingAttackFlow::PathGraph

// Main query to detect timing attack vulnerabilities
from
  TimingAttackFlow::PathNode secretOrigin,      // Origin of the secret data
  TimingAttackFlow::PathNode comparisonTarget    // Target comparison operation
where 
  // Verify existence of flow path from secret origin to comparison target
  TimingAttackFlow::flowPath(secretOrigin, comparisonTarget)
select 
  comparisonTarget.getNode(),   // Location where vulnerability manifests
  secretOrigin,                 // Origin of the flow
  comparisonTarget,             // Termination point of the flow
  "Timing attack against $@ verification.", // Security alert
  secretOrigin.getNode(),       // Reference point for alert
  "client-provided secret"      // Description of the sensitive source