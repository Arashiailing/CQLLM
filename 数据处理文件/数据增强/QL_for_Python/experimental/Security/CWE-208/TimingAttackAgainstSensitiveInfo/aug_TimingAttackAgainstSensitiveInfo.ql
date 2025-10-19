/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines that check secret values,
 *              potentially enabling timing attacks to extract sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack
import TimingAttackSensitiveFlow::PathGraph

/**
 * Configuration for tracking data flow from secret sources to unsafe comparisons.
 */
private module TimingAttackSensitiveConfig implements DataFlow::ConfigSig {
  /** Identifies nodes that represent sources of sensitive secrets */
  predicate isSource(DataFlow::Node secretOrigin) { 
    secretOrigin instanceof SecretSource 
  }

  /** Identifies nodes that represent vulnerable comparison operations */
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }

  /** Enables differential analysis in incremental mode */
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking module for secret-to-comparison flows */
module TimingAttackSensitiveFlow = 
  TaintTracking::Global<TimingAttackSensitiveConfig>;

from
  TimingAttackSensitiveFlow::PathNode secretOrigin,
  TimingAttackSensitiveFlow::PathNode vulnerableComparison
where
  // Ensure complete flow path exists between source and sink
  TimingAttackSensitiveFlow::flowPath(secretOrigin, vulnerableComparison) and
  // Verify either source or sink involves user-provided data
  (
    secretOrigin.getNode().(SecretSource).includesUserInput() or
    vulnerableComparison.getNode().(NonConstantTimeComparisonSink).includesUserInput()
  )
select 
  vulnerableComparison.getNode(), 
  secretOrigin, 
  vulnerableComparison, 
  "Timing attack against $@ validation.", 
  secretOrigin.getNode(),
  "client-supplied token"