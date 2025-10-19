/**
 * @name Timing attack against secret
 * @description Detects non-constant-time verification routines that could enable timing attacks 
 *              to retrieve sensitive information through side-channel analysis.
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

/**
 * Configuration for tracking data flow from secret sources to unsafe comparisons.
 */
private module SecretTimingConfig implements DataFlow::ConfigSig {
  // Identifies source nodes representing sensitive secrets
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // Identifies sink nodes representing vulnerable comparison operations
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // Enables differential analysis in incremental mode
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking module based on secret timing configuration
module SecretTimingFlow = TaintTracking::Global<SecretTimingConfig>;

// Import path graph for visualization of data flow paths
import SecretTimingFlow::PathGraph

/**
 * Finds paths where secrets flow through non-constant-time comparisons.
 */
from 
  SecretTimingFlow::PathNode originNode,  // Source node in data flow
  SecretTimingFlow::PathNode targetNode   // Sink node in data flow
where 
  // Data flow exists from source to sink
  SecretTimingFlow::flowPath(originNode, targetNode) and
  // Either source or sink involves user-controllable input
  (
    originNode.getNode().(SecretSource).includesUserInput() or
    targetNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
  )
select 
  targetNode.getNode(), 
  originNode, 
  targetNode, 
  "Timing attack vulnerability in $@ validation.", 
  originNode.getNode(), 
  "client-supplied token"