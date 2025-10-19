/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines for secret values,
 *              potentially enabling timing attacks to extract sensitive information.
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
// Import timing attack security analysis module
import experimental.semmle.python.security.TimingAttack

/**
 * Data flow configuration for tracking secret values to unsafe comparisons.
 * Defines sources (secrets) and sinks (non-constant-time comparisons).
 */
private module SecretTimingAttackConfig implements DataFlow::ConfigSig {
  // Identify secret sources as flow origins
  predicate isSource(DataFlow::Node origin) { origin instanceof SecretSource }

  // Identify non-constant-time comparisons as flow destinations
  predicate isSink(DataFlow::Node destination) { destination instanceof NonConstantTimeComparisonSink }

  // Enable differential analysis for all scenarios
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Define global taint tracking using the configuration
module SecretTimingAttackFlow = TaintTracking::Global<SecretTimingAttackConfig>;

// Import path graph for result visualization
import SecretTimingAttackFlow::PathGraph

// Query to identify timing attack paths from secrets to unsafe comparisons
from
  SecretTimingAttackFlow::PathNode secretOrigin,    // Source node (secret)
  SecretTimingAttackFlow::PathNode comparisonTarget  // Sink node (unsafe comparison)
where 
  SecretTimingAttackFlow::flowPath(secretOrigin, comparisonTarget)  // Path exists
select 
  comparisonTarget.getNode(),  // Vulnerable comparison location
  secretOrigin,                // Path start
  comparisonTarget,            // Path end
  "Timing attack against $@ validation.", 
  secretOrigin.getNode(),      // Annotated secret source
  "client-supplied token"      // Source description