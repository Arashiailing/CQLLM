/**
 * @name Insecure randomness
 * @description Detects security-critical operations utilizing cryptographically weak 
 *              pseudo-random number generators, which allows adversaries to forecast 
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

// Fundamental Python analysis framework
import python

// Specialized security module for identifying weak random patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow propagation mechanism
import semmle.python.dataflow.new.DataFlow

// Path visualization infrastructure for data flow
import InsecureRandomness::Flow::PathGraph

// Query detecting insecure random value propagation
from 
  InsecureRandomness::Flow::PathNode weakRandomSource,    // Origin of weak random value
  InsecureRandomness::Flow::PathNode securityCriticalSink  // Security-sensitive consumption point
where 
  // Validate data flow path from weak random source to critical sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securityCriticalSink)
select 
  securityCriticalSink.getNode(),                      // Target location of insecure usage
  weakRandomSource,                                    // Origin node for path tracking
  securityCriticalSink,                                // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  weakRandomSource.getNode(),                          // Reference node for alert message
  "random value"                                      // Description of vulnerable element