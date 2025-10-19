/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines for secret values,
 *              which could enable timing attacks exposing sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Core Python language analysis modules
import python
// Data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Taint propagation capabilities
import semmle.python.dataflow.new.TaintTracking
// Experimental timing attack detection utilities
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking data flow from secret origins to non-constant-time comparisons.
 * Identifies potential timing attack vulnerabilities in code.
 */
private module SecretComparisonConfig implements DataFlow::ConfigSig {
  // Define origins: nodes representing secret sources
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // Define targets: nodes representing non-constant-time comparison operations
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking using the secret comparison configuration
module SecretComparisonFlow = TaintTracking::Global<SecretComparisonConfig>;

// Path visualization module for flow paths
import SecretComparisonFlow::PathGraph

// Primary query to detect timing attack vulnerabilities
from
  SecretComparisonFlow::PathNode sourceNode,  // Origin of the secret data
  SecretComparisonFlow::PathNode sinkNode     // Target comparison operation
where 
  // Verify existence of flow path from secret origin to comparison target
  SecretComparisonFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(),      // Location where vulnerability manifests
  sourceNode,              // Origin of the flow
  sinkNode,                // Termination point of the flow
  "Timing attack against $@ verification.", // Security alert
  sourceNode.getNode(),    // Reference point for alert
  "client-provided secret" // Description of the sensitive source