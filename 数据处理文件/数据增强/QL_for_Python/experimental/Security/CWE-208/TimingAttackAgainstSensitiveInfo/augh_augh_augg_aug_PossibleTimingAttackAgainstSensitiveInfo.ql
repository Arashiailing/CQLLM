/**
 * @name Timing attack vulnerability in secret comparison
 * @description Detects verification routines comparing secret values without constant-time algorithms,
 *              potentially enabling timing attacks to expose sensitive data.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import required modules for analysis
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

// Define taint tracking configuration for timing attack analysis
private module TimingAttackTaintConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node origin) { origin instanceof SecretSource }
  predicate isSink(DataFlow::Node target) { target instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish taint tracking flow from secrets to comparisons
module SecretFlow = TaintTracking::Global<TimingAttackTaintConfig>;
import SecretFlow::PathGraph

// Define the main query to find timing attack vulnerability paths
from 
  SecretFlow::PathNode sourceNode, 
  SecretFlow::PathNode sinkNode
where 
  SecretFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack against $@ validation.", 
  sourceNode.getNode(), 
  "client-supplied token"