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
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Define taint tracking configuration and path graph
module SecretComparisonFlow = TaintTracking::Global<TimingFlowConfig>;
import SecretComparisonFlow::PathGraph

// Query to identify timing attack vulnerabilities
from SecretComparisonFlow::PathNode source, SecretComparisonFlow::PathNode sink
where SecretComparisonFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Timing attack against $@ validation.", source.getNode(), "client-supplied token"