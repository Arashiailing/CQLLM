/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines that may expose secrets
 *              through timing differences, enabling attackers to extract sensitive information.
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
 * Configuration for tracking data flow from secret sources to vulnerable comparison sinks.
 * Defines security boundaries for timing attack vulnerability detection.
 */
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  /**
   * Identifies sources of sensitive data that could be exposed through timing attacks.
   * Matches nodes representing client-supplied secrets or tokens.
   */
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof SecretSource 
  }

  /**
   * Identifies vulnerable sinks where non-constant-time comparisons occur.
   * Matches nodes performing unsafe comparisons of sensitive data.
   */
  predicate isSink(DataFlow::Node sinkNode) { 
    sinkNode instanceof NonConstantTimeComparisonSink 
  }

  /**
   * Enables incremental analysis mode for improved path detection.
   * Required for path-problem configurations.
   */
  predicate observeDiffInformedIncrementalMode() { 
    any() 
  }
}

// Initialize global taint tracking for timing attack detection
module TimingAttackFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import TimingAttackFlow::PathGraph

/**
 * Detects potential timing attack vulnerabilities by tracing data flow
 * from secret sources to non-constant-time comparison sinks.
 */
from
  TimingAttackFlow::PathNode pathSource, // Origin of sensitive data
  TimingAttackFlow::PathNode pathSink    // Destination with unsafe comparison
where
  // Verify complete data flow path exists from source to sink
  TimingAttackFlow::flowPath(pathSource, pathSink)
select
  pathSink.getNode(), // Location of vulnerable comparison
  pathSource,         // Source node in the flow path
  pathSink,           // Sink node in the flow path
  "Timing attack against $@ validation.", // Alert message
  pathSource.getNode(), // Source location reference
  "client-supplied token" // Description of sensitive source