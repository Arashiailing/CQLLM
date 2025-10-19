/**
 * @name Header value timing attack vulnerability
 * @description Identifies non-constant-time verification of HTTP header values,
 *              potentially enabling timing attacks to infer sensitive header data.
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
 * Configuration for tracking data flow from client-supplied secrets (via HTTP headers)
 * to unsafe comparison operations that may lead to timing attacks.
 */
private module HeaderTimingAttackConfig implements DataFlow::ConfigSig {
  // Source: Client-provided sensitive data from HTTP headers
  predicate isSource(DataFlow::Node source) { source instanceof ClientSuppliedSecret }

  // Sink: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node sink) { sink instanceof CompareSink }

  // Incremental mode configuration for differential observation
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module for header timing attacks
module HeaderTimingAttackFlow = TaintTracking::Global<HeaderTimingAttackConfig>;

import HeaderTimingAttackFlow::PathGraph

// Query to identify vulnerable timing attack paths
from
  HeaderTimingAttackFlow::PathNode tokenSource,
  HeaderTimingAttackFlow::PathNode compareSink
where
  // Valid flow path exists from source to sink
  HeaderTimingAttackFlow::flowPath(tokenSource, compareSink) and
  // Sink doesn't propagate to additional nodes
  not compareSink.getNode().(CompareSink).flowtolen()
select compareSink.getNode(), tokenSource, compareSink, "Timing attack against $@ validation.", tokenSource.getNode(),
  "client-supplied token"