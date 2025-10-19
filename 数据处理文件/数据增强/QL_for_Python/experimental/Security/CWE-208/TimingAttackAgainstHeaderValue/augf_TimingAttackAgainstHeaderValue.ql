/**
 * @name Timing attack against header value
 * @description Detects non-constant-time verification of HTTP header values,
 *              which could enable timing attacks to infer sensitive header values.
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
 * to vulnerable comparison operations in header validation.
 */
private module TimingAttackHeaderFlowConfig implements DataFlow::ConfigSig {
  // Identifies client-provided sensitive data as flow sources
  predicate isSource(DataFlow::Node secretSource) { 
    secretSource instanceof ClientSuppliedSecret 
  }

  // Identifies vulnerable comparison operations as flow sinks
  predicate isSink(DataFlow::Node comparisonSink) { 
    comparisonSink instanceof CompareSink 
  }

  // Enables differential analysis for timing attack detection
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module for header timing attack analysis
module TimingAttackHeaderFlowTracker = 
  TaintTracking::Global<TimingAttackHeaderFlowConfig>;

import TimingAttackHeaderFlowTracker::PathGraph

// Query to identify timing attack vulnerabilities in header validation
from
  TimingAttackHeaderFlowTracker::PathNode origin,
  TimingAttackHeaderFlowTracker::PathNode destination
where
  // Exists data flow path from source to sink
  TimingAttackHeaderFlowTracker::flowPath(origin, destination) and
  // Sink node doesn't propagate to further operations
  not destination.getNode().(CompareSink).flowtolen()
select 
  destination.getNode(), 
  origin, 
  destination, 
  "Timing attack against $@ validation.", 
  origin.getNode(), 
  "client-supplied token"