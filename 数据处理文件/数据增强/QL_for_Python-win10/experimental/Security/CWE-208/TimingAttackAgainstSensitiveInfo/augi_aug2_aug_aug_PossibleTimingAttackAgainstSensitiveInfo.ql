/**
 * @name Timing attack against secret
 * @description Identifies verification routines that don't operate in constant time when processing secret values,
 *              which could create timing attack vectors exposing sensitive information.
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
 * Configuration for tracking confidential data flow to non-constant-time comparison operations.
 * This module helps identify timing vulnerabilities by analyzing how sensitive data moves through the code.
 */
private module ConfidentialDataFlowConfig implements DataFlow::ConfigSig {
  // Define origins: nodes representing sources of confidential data
  predicate isSource(DataFlow::Node secretOrigin) { secretOrigin instanceof SecretSource }

  // Define targets: nodes representing comparison operations vulnerable to timing attacks
  predicate isSink(DataFlow::Node vulnerableComparison) { vulnerableComparison instanceof NonConstantTimeComparisonSink }

  // Enable differential observation mode for thorough analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish global taint tracking using the confidential data flow configuration
module ConfidentialDataFlowTracking = TaintTracking::Global<ConfidentialDataFlowConfig>;

// Import path visualization module for representing data flow paths
import ConfidentialDataFlowTracking::PathGraph

// Main query to detect timing attack vulnerability paths
from
  ConfidentialDataFlowTracking::PathNode secretOrigin,     // Starting point of the secret data
  ConfidentialDataFlowTracking::PathNode vulnerableComparison  // Vulnerable comparison operation
where 
  // Ensure there's a data flow path from the secret source to the vulnerable comparison
  ConfidentialDataFlowTracking::flowPath(secretOrigin, vulnerableComparison)
select 
  vulnerableComparison.getNode(),  // Location where the vulnerability is manifested
  secretOrigin,                    // Origin point of the data flow
  vulnerableComparison,            // End point of the data flow
  "Timing attack against $@ verification.", // Security warning message
  secretOrigin.getNode(),          // Reference point for the warning context
  "client-provided secret"         // Description of the sensitive data source