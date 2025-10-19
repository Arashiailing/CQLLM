/**
 * @name Header value timing attack vulnerability
 * @description Detects non-constant-time verification of HTTP header values,
 *              enabling timing attacks to infer sensitive header data.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/timing-attack-against-header-value
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking data flow from HTTP header secrets
 * to unsafe comparison operations vulnerable to timing attacks.
 */
private module HeaderTimingConfig implements DataFlow::ConfigSig {
  // Source: Client-supplied sensitive data from HTTP headers
  predicate isSource(DataFlow::Node source) { source instanceof ClientSuppliedSecret }

  // Sink: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node sink) { sink instanceof CompareSink }

  // Enable differential observation for incremental analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking for header timing vulnerabilities
module HeaderTimingFlow = TaintTracking::Global<HeaderTimingConfig>;

import HeaderTimingFlow::PathGraph

// Query identifying vulnerable timing attack paths
from
  HeaderTimingFlow::PathNode headerSource,
  HeaderTimingFlow::PathNode timingSink
where
  // Verify data flow path exists from source to sink
  HeaderTimingFlow::flowPath(headerSource, timingSink) and
  // Ensure sink doesn't propagate to additional nodes
  not timingSink.getNode().(CompareSink).flowtolen()
select timingSink.getNode(), headerSource, timingSink, "Timing attack against $@ validation.", headerSource.getNode(),
  "client-supplied token"