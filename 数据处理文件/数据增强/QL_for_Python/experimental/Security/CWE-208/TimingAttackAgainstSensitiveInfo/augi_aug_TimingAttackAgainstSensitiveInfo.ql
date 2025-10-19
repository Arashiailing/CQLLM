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
 * Configuration module for taint tracking from secret sources to vulnerable comparison operations.
 * This module defines the sources (sensitive secrets) and sinks (non-constant-time comparisons)
 * for detecting timing attack vulnerabilities.
 */
private module TimingAttackSensitiveConfig implements DataFlow::ConfigSig {
  /** Identifies nodes representing vulnerable comparison operations */
  predicate isSink(DataFlow::Node comparisonNode) { 
    comparisonNode instanceof NonConstantTimeComparisonSink 
  }

  /** Identifies nodes representing sources of sensitive secrets */
  predicate isSource(DataFlow::Node secretSource) { 
    secretSource instanceof SecretSource 
  }

  /** Enables differential analysis during incremental execution */
  predicate observeDiffInformedIncrementalMode() { any() }
}

/**
 * Global taint tracking module that propagates sensitive data from secret sources
 * to vulnerable comparison sinks, enabling detection of timing attack vulnerabilities.
 */
module TimingAttackSensitiveFlow = 
  TaintTracking::Global<TimingAttackSensitiveConfig>;

from
  TimingAttackSensitiveFlow::PathNode sourceNode,
  TimingAttackSensitiveFlow::PathNode sinkNode
where
  // Verify existence of complete data flow path from source to sink
  TimingAttackSensitiveFlow::flowPath(sourceNode, sinkNode)
  and
  // Ensure vulnerability involves user-provided data at either source or sink
  (
    sourceNode.getNode().(SecretSource).includesUserInput()
    or
    sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
  )
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack against $@ validation.", 
  sourceNode.getNode(),
  "client-supplied token"