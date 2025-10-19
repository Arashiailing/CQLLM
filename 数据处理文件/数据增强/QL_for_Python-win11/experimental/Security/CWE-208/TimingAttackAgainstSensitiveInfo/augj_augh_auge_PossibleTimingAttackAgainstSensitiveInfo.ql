/**
 * @name Timing attack against secret
 * @description Detects verification mechanisms that fail to employ constant-time comparison
 *              when checking secret values, potentially enabling timing attacks to
 *              reveal confidential information via response time variations.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import Python language support and security analysis modules
import python
import experimental.semmle.python.security.TimingAttack
// Import data flow and taint tracking frameworks
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking

/**
 * Configuration for tracking confidential data flows to insecure comparison operations.
 * This module establishes the origins (confidential data) and destinations (non-constant-time comparisons)
 * for identifying potential timing attack vulnerabilities.
 */
private module SecretTimingFlowConfig implements DataFlow::ConfigSig {
  // Define confidential data origins as flow starting points
  predicate isSource(DataFlow::Node dataOrigin) { dataOrigin instanceof SecretSource }

  // Detect non-constant-time comparisons as security weaknesses
  predicate isSink(DataFlow::Node vulnerableComparison) { vulnerableComparison instanceof NonConstantTimeComparisonSink }

  // Enable thorough differential analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Configure global taint tracking using the established configuration
module SecretTimingFlow = TaintTracking::Global<SecretTimingFlowConfig>;

// Import path graph for displaying data flow paths
import SecretTimingFlow::PathGraph

// Primary query to identify timing attack vulnerability paths
from
  SecretTimingFlow::PathNode sensitiveDataOrigin,    // Starting point of confidential data
  SecretTimingFlow::PathNode timingVulnerabilityTarget  // Insecure comparison operation
where 
  // Confirm existence of a data flow path from source to sink
  SecretTimingFlow::flowPath(sensitiveDataOrigin, timingVulnerabilityTarget)
select 
  timingVulnerabilityTarget.getNode(),  // Location of the insecure comparison
  sensitiveDataOrigin,                   // Origin of the vulnerability path
  timingVulnerabilityTarget,            // Termination point of the vulnerability path
  "Timing attack against $@ validation.", 
  sensitiveDataOrigin.getNode(),         // Annotated origin of confidential data
  "client-supplied token"               // Description of the confidential data source