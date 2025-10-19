/**
 * @name Timing attack against secret
 * @description Identifies verification processes that do not operate in constant time 
 *              when handling secret values, potentially enabling timing attacks 
 *              that expose sensitive information.
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
 * Configuration for tracking data flow from sensitive data origins 
 * to non-constant-time comparison operations. This setup identifies 
 * potential timing attack vulnerabilities in code.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  // Define origins: nodes representing sensitive data sources
  predicate isSource(DataFlow::Node sensitiveOrigin) { 
    sensitiveOrigin instanceof SecretSource 
  }

  // Define targets: nodes representing non-constant-time comparison operations
  predicate isSink(DataFlow::Node comparisonTarget) { 
    comparisonTarget instanceof NonConstantTimeComparisonSink 
  }

  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Establish global taint tracking using the timing attack configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackFlowConfig>;

// Import path visualization module for flow paths
import TimingAttackFlow::PathGraph

// Primary query to detect timing attack vulnerabilities
from
  TimingAttackFlow::PathNode secretOriginNode,  // Origin of the sensitive data
  TimingAttackFlow::PathNode comparisonSinkNode  // Target comparison operation
where 
  // Verify existence of flow path from sensitive origin to comparison target
  TimingAttackFlow::flowPath(secretOriginNode, comparisonSinkNode)
select 
  comparisonSinkNode.getNode(),      // Location where vulnerability manifests
  secretOriginNode,                  // Origin of the flow
  comparisonSinkNode,                // Termination point of the flow
  "Timing attack against $@ verification.", // Security alert
  secretOriginNode.getNode(),        // Reference point for alert
  "client-provided secret"           // Description of the sensitive source