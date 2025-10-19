/**
 * @name Insecure randomness
 * @description Detects security-critical operations utilizing 
 *              cryptographically weak pseudo-random number generators, 
 *              which allow attackers to forecast generated values and 
 *              undermine system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Fundamental Python language analysis infrastructure
import python

// Specialized security module for identifying weak random number generation
import experimental.semmle.python.security.InsecureRandomness

// Data flow propagation and tracking framework
import semmle.python.dataflow.new.DataFlow

// Path visualization components for data flow analysis
import InsecureRandomness::Flow::PathGraph

// Query identifying insecure random value propagation paths
from 
  InsecureRandomness::Flow::PathNode weakRndSource,      // Origin of insecure random value
  InsecureRandomness::Flow::PathNode sensitiveSink        // Security-sensitive consumption point
where 
  // Verify data flow propagation from source to sink
  InsecureRandomness::Flow::flowPath(weakRndSource, sensitiveSink)
select 
  sensitiveSink.getNode(),                              // Vulnerable usage location
  weakRndSource,                                        // Path origin for tracking
  sensitiveSink,                                        // Visualization sink node
  "Cryptographically insecure $@ in security context.", // Alert message
  weakRndSource.getNode(),                              // Reference node for alert
  "random value"                                        // Vulnerable element description