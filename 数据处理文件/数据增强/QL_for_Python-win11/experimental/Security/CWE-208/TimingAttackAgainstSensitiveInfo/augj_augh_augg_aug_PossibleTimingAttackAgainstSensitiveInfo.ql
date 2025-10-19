/**
 * @name Timing attack vulnerability in secret comparison
 * @description Detects validation functions that compare sensitive values without
 *              constant-time algorithms, potentially enabling timing attacks to expose secrets.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import necessary modules for the analysis
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

// Configuration for taint tracking in timing attack analysis
private module TimingAttackFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish taint propagation from secrets to vulnerable comparisons
module SecretFlow = TaintTracking::Global<TimingAttackFlowConfig>;
import SecretFlow::PathGraph

// Main query to identify timing attack vulnerability paths
from 
  SecretFlow::PathNode secretSourceNode, 
  SecretFlow::PathNode vulnerableComparisonNode
where 
  SecretFlow::flowPath(secretSourceNode, vulnerableComparisonNode)
select 
  vulnerableComparisonNode.getNode(), 
  secretSourceNode, 
  vulnerableComparisonNode, 
  "Timing attack against $@ validation.", 
  secretSourceNode.getNode(), 
  "client-supplied token"