/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines that may allow timing attacks to retrieve sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration tracking data flow from secret sources to unsafe comparisons.
 * Implements data flow signature for timing attack detection.
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node origin) { origin instanceof SecretSource }

  predicate isSink(DataFlow::Node destination) { destination instanceof NonConstantTimeComparisonSink }

  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module for timing attack paths
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;

import TimingAttackFlow::PathGraph

from
  TimingAttackFlow::PathNode origin,      // Source node representing secret origin
  TimingAttackFlow::PathNode destination   // Sink node representing vulnerable comparison
where
  TimingAttackFlow::flowPath(origin, destination)  // Condition: data flow exists
select
  destination.getNode(),                   // Target node for result display
  origin, destination,                     // Path components
  "Timing attack against $@ validation.",   // Alert message
  origin.getNode(),                        // Source node reference
  "client-supplied token"                  // Source description