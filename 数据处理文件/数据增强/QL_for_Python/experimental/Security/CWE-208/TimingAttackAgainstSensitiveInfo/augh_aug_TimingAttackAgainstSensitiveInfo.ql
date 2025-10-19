/**
 * @name Timing attack against secret
 * @description Identifies non-constant-time verification routines that check secret values,
 *              which could enable timing attacks to extract sensitive information.
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
private module SecretToComparisonFlowConfig implements DataFlow::ConfigSig {
  /** Identifies nodes that represent sources of sensitive secrets */
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof SecretSource 
  }

  /** Identifies nodes that represent vulnerable comparison operations */
  predicate isSink(DataFlow::Node sinkNode) { 
    sinkNode instanceof NonConstantTimeComparisonSink 
  }

  /** Enables differential analysis in incremental mode */
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint tracking module for secret-to-comparison flows */
module TimingAttackSensitiveFlow = 
  TaintTracking::Global<SecretToComparisonFlowConfig>;

from
  TimingAttackSensitiveFlow::PathNode sourceNode,
  TimingAttackSensitiveFlow::PathNode sinkNode
where
  // Ensure complete flow path exists between source and sink
  TimingAttackSensitiveFlow::flowPath(sourceNode, sinkNode) and
  // Verify either source or sink involves user-provided data
  (
    sourceNode.getNode().(SecretSource).includesUserInput() or
    sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
  )
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack against $@ validation.", 
  sourceNode.getNode(),
  "client-supplied token"