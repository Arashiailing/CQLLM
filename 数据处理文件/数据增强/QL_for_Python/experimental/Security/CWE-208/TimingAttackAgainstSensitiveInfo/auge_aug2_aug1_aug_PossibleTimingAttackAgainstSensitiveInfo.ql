/**
 * @name Timing attack against secret
 * @description Identifies verification routines that do not use constant-time comparison 
 *              when checking secret values, potentially enabling timing attacks to 
 *              extract sensitive information.
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
 * Taint tracking configuration for timing attack analysis.
 * Tracks data flow from sensitive sources to unsafe comparisons.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  // Identify sensitive data sources (secrets/tokens)
  predicate isSource(DataFlow::Node src) { 
    src instanceof SecretSource 
  }

  // Identify vulnerable sinks (non-constant-time comparisons)
  predicate isSink(DataFlow::Node snk) { 
    snk instanceof NonConstantTimeComparisonSink 
  }

  // Enable incremental path computation
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Initialize taint tracking with custom configuration
module SecretComparisonFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import SecretComparisonFlow::PathGraph

// Main query to detect timing attack vulnerabilities
from 
  SecretComparisonFlow::PathNode sourceNode, 
  SecretComparisonFlow::PathNode sinkNode
where 
  SecretComparisonFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack against $@ validation.", 
  sourceNode.getNode(), 
  "client-supplied token"