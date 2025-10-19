/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines that check secret values,
 *              potentially enabling timing attacks to extract sensitive information.
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
 * Configuration for tracking data flow from client secrets to unsafe comparisons.
 * Implements DataFlow::ConfigSig to define sources and sinks for timing attack analysis.
 */
private module ClientSecretToComparisonConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Define taint tracking flow from secrets to comparisons
module SecretToComparisonFlow = TaintTracking::Global<ClientSecretToComparisonConfig>;
import SecretToComparisonFlow::PathGraph

// Query to identify timing attack vulnerability paths
from SecretToComparisonFlow::PathNode secretOrigin, SecretToComparisonFlow::PathNode comparisonSink
where SecretToComparisonFlow::flowPath(secretOrigin, comparisonSink)
select comparisonSink.getNode(), secretOrigin, comparisonSink, "Timing attack against $@ validation.", secretOrigin.getNode(), "client-supplied token"