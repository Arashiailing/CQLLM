/**
 * @name Timing attack against secret
 * @description Use of a non-constant-time verification routine to check the value of an secret,
 *              possibly allowing a timing attack to retrieve sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import Python language support
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities
import semmle.python.dataflow.new.TaintTracking
// Import timing attack detection module
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracing data flow from client secret sources to non-constant-time comparison sinks.
 * This module defines the sources and sinks for timing attack vulnerability detection.
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { src instanceof SecretSource }
  predicate isSink(DataFlow::Node snk) { snk instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking flow for timing attack detection
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;
import TimingAttackFlow::PathGraph

// Query to detect timing attack paths from secret sources to unsafe comparisons
from
  TimingAttackFlow::PathNode source, // Origin of sensitive data
  TimingAttackFlow::PathNode sink    // Destination with unsafe comparison
where
  TimingAttackFlow::flowPath(source, sink) // Data flow path exists
select
  sink.getNode(), // Vulnerable comparison location
  source,         // Source node in the flow
  sink,           // Sink node in the flow
  "Timing attack against $@ validation.", // Alert message
  source.getNode(), // Source location reference
  "client-supplied token" // Source description