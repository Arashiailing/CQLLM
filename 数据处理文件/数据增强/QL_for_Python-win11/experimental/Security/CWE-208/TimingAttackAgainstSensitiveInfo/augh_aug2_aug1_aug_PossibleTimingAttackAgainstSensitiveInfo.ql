/**
 * @name Timing attack against secret
 * @description Detects verification mechanisms that perform non-constant-time 
 *              comparisons of secret values, potentially enabling timing attacks 
 *              to leak sensitive information through side channels.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import required analysis modules
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Taint tracking configuration for identifying timing attack vulnerabilities
 * by tracking data flow from sensitive sources to unsafe comparison operations.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  // Identify sensitive data sources (secrets, tokens, etc.)
  predicate isSource(DataFlow::Node source) { 
    source instanceof SecretSource 
  }

  // Identify vulnerable sinks (non-constant-time comparisons)
  predicate isSink(DataFlow::Node sink) { 
    sink instanceof NonConstantTimeComparisonSink 
  }

  // Enable incremental path computation mode
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Initialize taint tracking using the timing attack flow configuration
module TimingAttackFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import TimingAttackFlow::PathGraph

// Query to detect potential timing attack vulnerabilities
from 
  TimingAttackFlow::PathNode source, 
  TimingAttackFlow::PathNode sink
where 
  TimingAttackFlow::flowPath(source, sink)
select 
  sink.getNode(), 
  source, 
  sink, 
  "Timing attack against $@ validation.", 
  source.getNode(), 
  "client-supplied token"