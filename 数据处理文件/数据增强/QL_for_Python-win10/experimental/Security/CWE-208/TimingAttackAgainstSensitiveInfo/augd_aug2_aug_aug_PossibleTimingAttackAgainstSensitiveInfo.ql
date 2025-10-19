/**
 * @name Timing attack against secret
 * @description Identifies verification routines that don't use constant-time comparison
 *              for secret values, potentially creating timing attack vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Core Python language analysis and data flow frameworks
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for tracking sensitive data flow to non-constant-time comparisons.
 * This module defines the sources and sinks for timing vulnerability analysis.
 */
private module SensitiveDataFlowConfig implements DataFlow::ConfigSig {
  // Sources represent locations where sensitive/secret data originates
  predicate isSource(DataFlow::Node origin) { origin instanceof SecretSource }

  // Sinks represent vulnerable operations that compare data non-constantly
  predicate isSink(DataFlow::Node target) { target instanceof NonConstantTimeComparisonSink }

  // Enable enhanced differential observation for thorough analysis
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Initialize global taint tracking with the sensitive data flow configuration
module SensitiveDataFlowTracker = TaintTracking::Global<SensitiveDataFlowConfig>;
import SensitiveDataFlowTracker::PathGraph

// Main vulnerability detection query
from
  SensitiveDataFlowTracker::PathNode secretOrigin,    // Source of the secret data
  SensitiveDataFlowTracker::PathNode vulnerableComparison  // Vulnerable comparison operation
where 
  // Confirm data flows from secret source to vulnerable comparison
  SensitiveDataFlowTracker::flowPath(secretOrigin, vulnerableComparison)
select 
  vulnerableComparison.getNode(),    // Location where vulnerability occurs
  secretOrigin,                      // Origin of the sensitive data
  vulnerableComparison,              // Endpoint of the data flow
  "Timing attack against $@ verification.", // Security warning message
  secretOrigin.getNode(),            // Context reference for the alert
  "client-provided secret"           // Description of the sensitive data