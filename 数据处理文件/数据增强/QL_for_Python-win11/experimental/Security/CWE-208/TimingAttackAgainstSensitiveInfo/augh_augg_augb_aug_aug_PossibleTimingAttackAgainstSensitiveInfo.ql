/**
 * @name Timing attack against secret
 * @description Detects verification processes that fail to maintain constant-time 
 *              execution when handling secret values, potentially enabling timing 
 *              attacks that could expose sensitive information.
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
 * Configuration for tracking data flow from sensitive data sources 
 * to non-constant-time comparison operations. This identifies 
 * potential timing attack vulnerabilities in code.
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // Define sources: nodes representing sensitive data origins
  predicate isSource(DataFlow::Node secretSource) { 
    secretSource instanceof SecretSource 
  }

  // Define sinks: nodes representing non-constant-time comparisons
  predicate isSink(DataFlow::Node nonConstantTimeOp) { 
    nonConstantTimeOp instanceof NonConstantTimeComparisonSink 
  }

  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Establish global taint tracking using the timing attack configuration
module TimingAttackTaintFlow = TaintTracking::Global<TimingAttackConfig>;

// Import path visualization module for flow paths
import TimingAttackTaintFlow::PathGraph

// Main query to detect timing attack vulnerabilities
from
  TimingAttackTaintFlow::PathNode sourceNode,    // Origin of sensitive data
  TimingAttackTaintFlow::PathNode sinkNode      // Target comparison operation
where 
  // Verify existence of flow path from source to sink
  TimingAttackTaintFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(),              // Location where vulnerability manifests
  sourceNode,                      // Origin of the flow
  sinkNode,                        // Termination point of the flow
  "Timing attack against $@ verification.", // Security alert
  sourceNode.getNode(),            // Reference point for alert
  "client-provided secret"         // Description of the sensitive source