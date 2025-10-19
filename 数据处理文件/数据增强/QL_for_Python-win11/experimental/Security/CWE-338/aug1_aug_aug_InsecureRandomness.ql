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

// Core Python analysis module
import python

// Specialized security module for detecting insecure random patterns
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking framework
import semmle.python.dataflow.new.DataFlow

// Path graph representation for data flow visualization
import InsecureRandomness::Flow::PathGraph

// Query identifying insecure random value flows
from 
  InsecureRandomness::Flow::PathNode insecureSourceNode,  // Origin of insecure random value
  InsecureRandomness::Flow::PathNode sensitiveSinkNode     // Security-sensitive usage point
where 
  // Verify data flow path exists from weak random source to sensitive sink
  InsecureRandomness::Flow::flowPath(insecureSourceNode, sensitiveSinkNode)
select 
  sensitiveSinkNode.getNode(),                      // Target location of insecure usage
  insecureSourceNode,                                // Origin node for path tracking
  sensitiveSinkNode,                                 // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  insecureSourceNode.getNode(),                      // Reference node for alert message
  "random value"                                    // Description of vulnerable element