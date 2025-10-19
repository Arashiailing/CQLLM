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
 * Configuration for tracking data flow from sensitive sources to vulnerable comparison operations.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node sensitiveSource) { 
    sensitiveSource instanceof SecretSource 
  }
  
  predicate isSink(DataFlow::Node unsafeComparisonSink) { 
    unsafeComparisonSink instanceof NonConstantTimeComparisonSink 
  }
  
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Taint tracking configuration for secret flows to unsafe comparisons
module SecretToComparisonFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import SecretToComparisonFlow::PathGraph

// Query detecting timing attack vulnerabilities
from 
  SecretToComparisonFlow::PathNode secretSourceNode, 
  SecretToComparisonFlow::PathNode vulnerableComparisonNode
where 
  SecretToComparisonFlow::flowPath(secretSourceNode, vulnerableComparisonNode)
select 
  vulnerableComparisonNode.getNode(), 
  secretSourceNode, 
  vulnerableComparisonNode, 
  "Timing attack against $@ validation.", 
  secretSourceNode.getNode(), 
  "client-supplied token"