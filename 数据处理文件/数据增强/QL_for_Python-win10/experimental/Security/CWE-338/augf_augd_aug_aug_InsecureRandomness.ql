/**
 * @name Insecure randomness
 * @description Detects utilization of cryptographically weak pseudo-random number generators
 *              within security-sensitive operations, potentially allowing adversaries to forecast
 *              generated values and undermine system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import Python core library for code analysis capabilities
import python

// Import security module specialized in identifying weak random number patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow framework for tracking value propagation trajectories
import semmle.python.dataflow.new.DataFlow

// Import path graph module for visualizing data flow trajectories
import InsecureRandomness::Flow::PathGraph

// Query definition: Trace data flow from weak random sources to security-critical sinks
from 
  InsecureRandomness::Flow::PathNode weakRandomSource,    // Origin point of weak random value
  InsecureRandomness::Flow::PathNode securityCriticalSink // Security-critical usage point
where 
  // Validate existence of data flow path between source and sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securityCriticalSink)
select 
  securityCriticalSink.getNode(),                      // Target location of insecure value usage
  weakRandomSource,                                    // Origin point for path visualization
  securityCriticalSink,                                // Sink point for path visualization
  "Cryptographically insecure $@ in security context.", // Alert message template
  weakRandomSource.getNode(),                          // Reference node for message context
  "random value"                                      // Description of vulnerable element