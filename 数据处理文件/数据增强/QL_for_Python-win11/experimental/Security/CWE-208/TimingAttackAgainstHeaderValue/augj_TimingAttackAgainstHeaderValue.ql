/**
 * @name Timing attack against header value
 * @description Detects non-constant-time verification of HTTP header values,
 *              which could enable timing attacks to infer expected header values.
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
 * Configuration for tracking taint flow from client secrets to unsafe comparisons.
 * Implements data flow source/sink definitions for timing attack detection.
 */
private module HeaderTimingAttackConfig implements DataFlow::ConfigSig {
  // Identify client-supplied secrets as data flow sources
  predicate isSource(DataFlow::Node secretNode) { 
    secretNode instanceof ClientSuppliedSecret 
  }

  // Identify unsafe comparison operations as data flow sinks
  predicate isSink(DataFlow::Node comparisonSink) { 
    comparisonSink instanceof CompareSink 
  }

  // Enable differential analysis for timing side-channels
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module using the defined configuration
module HeaderTimingAttackFlow = TaintTracking::Global<HeaderTimingAttackConfig>;

import HeaderTimingAttackFlow::PathGraph

// Main query detecting timing attack vulnerabilities
from
  HeaderTimingAttackFlow::PathNode secretNode,  // Origin of client secret
  HeaderTimingAttackFlow::PathNode comparisonNode  // Vulnerable comparison operation
where
  // Verify complete taint flow path exists
  HeaderTimingAttackFlow::flowPath(secretNode, comparisonNode) and
  // Ensure sink isn't part of validated flow (false positive prevention)
  not comparisonNode.getNode().(CompareSink).flowtolen()
select comparisonNode.getNode(), 
       secretNode, 
       comparisonNode, 
       "Timing attack vulnerability in $@ validation.", 
       secretNode.getNode(), 
       "client-supplied secret"