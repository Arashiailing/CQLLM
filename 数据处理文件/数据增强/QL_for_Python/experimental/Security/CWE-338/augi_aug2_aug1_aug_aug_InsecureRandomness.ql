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

// Core Python analysis infrastructure
import python

// Security module for detecting weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking mechanism
import semmle.python.dataflow.new.DataFlow

// Path graph for visualizing data flow
import InsecureRandomness::Flow::PathGraph

// Query that identifies insecure random value flows
from 
  InsecureRandomness::Flow::PathNode insecureRandomSource,  // Origin of weak random value
  InsecureRandomness::Flow::PathNode sensitiveSink          // Security-sensitive consumption point
where 
  // Verify data flow propagation from source to sink
  InsecureRandomness::Flow::flowPath(
    insecureRandomSource, 
    sensitiveSink
  )
select 
  sensitiveSink.getNode(),                          // Target location of insecure usage
  insecureRandomSource,                            // Origin node for path tracking
  sensitiveSink,                                    // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  insecureRandomSource.getNode(),                  // Reference node for alert message
  "random value"                                   // Description of vulnerable element