/**
 * @name Timing attack against header value
 * @description Non-constant-time verification of HTTP header values may enable
 *              timing attacks to infer expected header values.
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
 * Configuration tracking data flow from client secrets in HTTP headers
 * to vulnerable comparison operations.
 */
private module HeaderValueTimingConfig implements DataFlow::ConfigSig {
  // Identifies client-provided sensitive data as flow sources
  predicate isSource(DataFlow::Node source) { source instanceof ClientSuppliedSecret }

  // Identifies comparison operations vulnerable to timing attacks as sinks
  predicate isSink(DataFlow::Node sink) { sink instanceof CompareSink }

  // Allows all incremental analysis modes
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module for header timing attack analysis
module HeaderValueTimingFlow = TaintTracking::Global<HeaderValueTimingConfig>;

import HeaderValueTimingFlow::PathGraph

// Identifies vulnerable validation paths from client tokens to comparisons
from
  HeaderValueTimingFlow::PathNode origin,
  HeaderValueTimingFlow::PathNode target
where
  // Requires complete flow path from source to sink
  HeaderValueTimingFlow::flowPath(origin, target) and
  // Excludes sinks that propagate to safe comparisons
  not target.getNode().(CompareSink).flowtolen()
select target.getNode(), origin, target, "Timing attack against $@ validation.", origin.getNode(),
  "client-supplied token"