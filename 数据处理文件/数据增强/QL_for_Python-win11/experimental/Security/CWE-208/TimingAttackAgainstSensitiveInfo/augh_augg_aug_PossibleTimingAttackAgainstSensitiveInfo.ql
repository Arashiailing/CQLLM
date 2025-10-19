/**
 * @name Timing attack vulnerability in secret comparison
 * @description Identifies verification routines that compare secret values without using
 *              constant-time algorithms, which could allow timing attacks to reveal sensitive data.
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
private module ClientSecretToComparisonConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish taint tracking flow from secrets to comparisons
module SecretToComparisonFlow = TaintTracking::Global<ClientSecretToComparisonConfig>;
import SecretToComparisonFlow::PathGraph

// Define the main query to find timing attack vulnerability paths
from 
  SecretToComparisonFlow::PathNode secretSourceNode, 
  SecretToComparisonFlow::PathNode vulnerableComparisonNode
where 
  SecretToComparisonFlow::flowPath(secretSourceNode, vulnerableComparisonNode)
select 
  vulnerableComparisonNode.getNode(), 
  secretSourceNode, 
  vulnerableComparisonNode, 
  "Timing attack against $@ validation.", 
  secretSourceNode.getNode(), 
  "client-supplied token"