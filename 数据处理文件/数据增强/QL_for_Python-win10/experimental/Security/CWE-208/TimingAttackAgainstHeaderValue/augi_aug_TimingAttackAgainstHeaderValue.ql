/**
 * @name Header value timing attack vulnerability
 * @description Detects non-constant-time verification of HTTP header values,
 *              which could enable attackers to infer sensitive header data through timing side channels.
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
 * Taint tracking configuration for header timing attacks.
 * This module defines sources (client-supplied secrets) and sinks (vulnerable comparisons).
 */
private module HeaderTimingConfig implements DataFlow::ConfigSig {
  // Source: Client-provided sensitive data from HTTP headers
  predicate isSource(DataFlow::Node origin) { origin instanceof ClientSuppliedSecret }

  // Sink: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node target) { target instanceof CompareSink }

  // Enable differential analysis for incremental detection
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking for header timing vulnerabilities
module HeaderTimingFlow = TaintTracking::Global<HeaderTimingConfig>;

import HeaderTimingFlow::PathGraph

// Identify vulnerable timing attack paths
from
  HeaderTimingFlow::PathNode secretOrigin,
  HeaderTimingFlow::PathNode comparisonTarget
where
  // Valid taint flow path exists from source to sink
  HeaderTimingFlow::flowPath(secretOrigin, comparisonTarget) and
  // Ensure sink doesn't propagate to additional nodes
  not comparisonTarget.getNode().(CompareSink).flowtolen()
select comparisonTarget.getNode(), secretOrigin, comparisonTarget, "Timing attack against $@ validation.", secretOrigin.getNode(),
  "client-supplied secret"