/**
 * @name Insecure randomness
 * @description Identifies security-sensitive operations that employ 
 *              cryptographically weak pseudo-random number generators, 
 *              enabling attackers to predict generated values and 
 *              compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Core Python language analysis framework
import python

// Security analysis module specialized for detecting weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Data flow tracking and propagation engine
import semmle.python.dataflow.new.DataFlow

// Visualization components for data flow paths
import InsecureRandomness::Flow::PathGraph

// Query for detecting propagation of insecure random values
from 
  InsecureRandomness::Flow::PathNode insecureRndSrc,    // Starting point of insecure random value
  InsecureRandomness::Flow::PathNode sensitiveUsePoint  // Security-sensitive destination
where 
  // Establish data flow connection between source and sink
  InsecureRandomness::Flow::flowPath(insecureRndSrc, sensitiveUsePoint)
select 
  sensitiveUsePoint.getNode(),                      // Target location of insecure usage
  insecureRndSrc,                                    // Origin node for path tracking
  sensitiveUsePoint,                                // Sink node for visualization
  "Cryptographically insecure $@ in security context.", // Alert description
  insecureRndSrc.getNode(),                         // Reference node for alert message
  "random value"                                    // Description of vulnerable element