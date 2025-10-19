/**
 * @name Insecure randomness
 * @description Identifies security-sensitive operations using cryptographically weak 
 *              pseudo-random number generators, enabling attackers to predict generated
 *              values and compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python analysis capabilities
import python

// Import specialized security module for insecure randomness detection
import experimental.semmle.python.security.InsecureRandomness

// Import data flow tracking framework
import semmle.python.dataflow.new.DataFlow

// Import path graph visualization components
import InsecureRandomness::Flow::PathGraph

// Query detects data flows from weak random sources to security-sensitive contexts
from 
  InsecureRandomness::Flow::PathNode weakRandomSource,    // Origin of insecure random value
  InsecureRandomness::Flow::PathNode securitySensitiveSink // Security-critical usage point
where 
  // Verify data flow path exists between source and sink
  InsecureRandomness::Flow::flowPath(weakRandomSource, securitySensitiveSink)
select 
  securitySensitiveSink.getNode(),                      // Target location of insecure usage
  weakRandomSource,                                      // Origin node for path tracking
  securitySensitiveSink,                                 // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  weakRandomSource.getNode(),                           // Reference node for alert message
  "random value"                                        // Description of vulnerable element