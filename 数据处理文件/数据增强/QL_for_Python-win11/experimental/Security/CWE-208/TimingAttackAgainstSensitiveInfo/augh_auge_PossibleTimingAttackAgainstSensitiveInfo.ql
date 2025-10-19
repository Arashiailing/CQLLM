/**
 * @name Timing attack against secret
 * @description Identifies verification routines that do not use constant-time comparison
 *              when validating secret values, which could allow timing attacks to
 *              extract sensitive information through response time differences.
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
 * Configuration module for tracking sensitive data flows to vulnerable comparison operations.
 * This module defines the sources (sensitive data) and sinks (non-constant-time comparisons)
 * for detecting potential timing attack vulnerabilities.
 */
private module SensitiveDataTimingAnalysisConfig implements DataFlow::ConfigSig {
  // Define sensitive data sources as flow origins
  predicate isSource(DataFlow::Node sourceNode) { sourceNode instanceof SecretSource }

  // Identify non-constant-time comparisons as vulnerable targets
  predicate isSink(DataFlow::Node targetNode) { targetNode instanceof NonConstantTimeComparisonSink }

  // Enable comprehensive differential analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Establish global taint tracking using the defined configuration
module SensitiveDataTimingFlow = TaintTracking::Global<SensitiveDataTimingAnalysisConfig>;

// Import path graph for visualization of data flow paths
import SensitiveDataTimingFlow::PathGraph

// Main query to detect timing attack vulnerability paths
from
  SensitiveDataTimingFlow::PathNode secretSourceNode,    // Origin point of sensitive data
  SensitiveDataTimingFlow::PathNode vulnerabilityTargetNode  // Vulnerable comparison operation
where 
  // Verify that a data flow path exists from source to sink
  SensitiveDataTimingFlow::flowPath(secretSourceNode, vulnerabilityTargetNode)
select 
  vulnerabilityTargetNode.getNode(),  // Location of the vulnerable comparison
  secretSourceNode,                   // Starting point of the vulnerability path
  vulnerabilityTargetNode,            // Ending point of the vulnerability path
  "Timing attack against $@ validation.", 
  secretSourceNode.getNode(),         // Annotated source of sensitive data
  "client-supplied token"             // Description of the sensitive data source