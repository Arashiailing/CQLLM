/**
 * @name Timing attack on header value verification
 * @description Detects non-constant-time header value verification that could enable
 *              timing attacks to infer sensitive header values through response time analysis.
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
 * Configuration for tracking data flow from client-supplied secrets
 * (obtained via HTTP headers) to unsafe comparison operations.
 */
module HeaderTimingAttackConfig implements DataFlow::ConfigSig {
  // Identifies source nodes representing client-provided secrets
  predicate isSource(DataFlow::Node source) { source instanceof ClientSuppliedSecret }

  // Identifies sink nodes representing vulnerable comparison operations
  predicate isSink(DataFlow::Node sink) { sink instanceof CompareSink }

  // Enables differential observation in incremental analysis mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module for detecting timing attack paths
module HeaderTimingAttackFlow = TaintTracking::Global<HeaderTimingAttackConfig>;

import HeaderTimingAttackFlow::PathGraph

// Query to identify potential timing attack paths
from
  HeaderTimingAttackFlow::PathNode sourceNode,
  HeaderTimingAttackFlow::PathNode sinkNode
where
  // Conditions: Flow path exists from source to sink, and sink doesn't propagate further
  HeaderTimingAttackFlow::flowPath(sourceNode, sinkNode) and
  not sinkNode.getNode().(CompareSink).flowtolen()
select sinkNode.getNode(), sourceNode, sinkNode, "Timing attack vulnerability in $@ validation.", sourceNode.getNode(),
  "client-supplied token"