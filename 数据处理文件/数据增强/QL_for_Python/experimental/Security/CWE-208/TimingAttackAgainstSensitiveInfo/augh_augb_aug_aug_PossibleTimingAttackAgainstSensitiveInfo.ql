/**
 * @name Secret value timing attack vulnerability
 * @description Identifies verification processes that do not use constant-time comparison for secret data,
 *              which could lead to timing attacks revealing confidential information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import core Python language analysis modules
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint propagation capabilities
import semmle.python.dataflow.new.TaintTracking
// Import experimental timing attack detection utilities
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration module designed to trace data flow from sources of secrets to comparison operations
 * that are not constant-time. This configuration aids in detecting potential timing attack flaws.
 */
private module SecretComparisonConfig implements DataFlow::ConfigSig {
  // Define origins: nodes representing secret sources
  predicate isSource(DataFlow::Node secretOriginNode) { secretOriginNode instanceof SecretSource }

  // Define targets: nodes representing non-constant-time comparison operations
  predicate isSink(DataFlow::Node comparisonSinkNode) { comparisonSinkNode instanceof NonConstantTimeComparisonSink }

  // Enable differential observation mode for all scenarios
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish global taint tracking using the secret comparison configuration
module SecretComparisonFlow = TaintTracking::Global<SecretComparisonConfig>;

// Import path visualization module for flow paths
import SecretComparisonFlow::PathGraph

// Primary query to detect timing attack vulnerabilities
from
  SecretComparisonFlow::PathNode secretOriginNode,  // Node representing the source of the secret
  SecretComparisonFlow::PathNode comparisonSinkNode  // Node representing the non-constant-time comparison
where 
  // Ensure there is a data flow path from the secret source to the comparison sink
  SecretComparisonFlow::flowPath(secretOriginNode, comparisonSinkNode)
select 
  comparisonSinkNode.getNode(),  // Location of the vulnerable comparison
  secretOriginNode,              // Source node of the flow
  comparisonSinkNode,            // Sink node of the flow
  "Timing attack against $@ verification.", // Alert message
  secretOriginNode.getNode(),    // Reference to the source node in the alert
  "client-provided secret"       // Description of the secret source