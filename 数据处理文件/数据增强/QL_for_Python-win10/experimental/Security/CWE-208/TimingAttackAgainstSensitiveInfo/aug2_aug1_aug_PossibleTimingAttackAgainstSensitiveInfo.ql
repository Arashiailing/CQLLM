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

// Import necessary modules
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Flow configuration to track data flow from sensitive sources 
 * to unsafe comparison operations.
 */
private module TimingFlowConfig implements DataFlow::ConfigSig {
  // Define sensitive data sources (e.g., secrets, tokens)
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof SecretSource 
  }

  // Define vulnerable sinks (non-constant-time comparisons)
  predicate isSink(DataFlow::Node sinkNode) { 
    sinkNode instanceof NonConstantTimeComparisonSink 
  }

  // Enable incremental mode for path computation
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Configure taint tracking with the defined flow configuration
module SecretComparisonFlow = TaintTracking::Global<TimingFlowConfig>;
import SecretComparisonFlow::PathGraph

// Query to detect timing attack vulnerabilities
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