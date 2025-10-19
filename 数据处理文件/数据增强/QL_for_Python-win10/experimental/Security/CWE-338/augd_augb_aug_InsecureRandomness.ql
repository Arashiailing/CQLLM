/**
 * @name Insecure randomness vulnerability
 * @description Identifies usage of cryptographically weak pseudo-random number generators
 *              for creating security-sensitive values, potentially allowing attackers
 *              to predict generated values and compromise security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python analysis capabilities for code examination
import python

// Import specialized security analysis module for detecting insecure random
// number generation patterns in Python applications
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis framework to trace value propagation
// through program execution paths
import semmle.python.dataflow.new.DataFlow

// Import path graph module for visualizing and representing data
// flow connections between source and sink points
import InsecureRandomness::Flow::PathGraph

// Query to trace insecure random value propagation:
// - insecureRandomSource: Origin point of cryptographically weak random values
// - securitySensitiveSink: Security-critical usage point of these values
from InsecureRandomness::Flow::PathNode insecureRandomSource, 
     InsecureRandomness::Flow::PathNode securitySensitiveSink
where 
  // Establish data flow connection between source and sink
  InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select 
  // Output the sink node as primary result
  securitySensitiveSink.getNode(), 
  // Include source and sink nodes for path visualization
  insecureRandomSource, 
  securitySensitiveSink, 
  // Generate alert message with source node reference
  "Cryptographically insecure $@ in a security context.",
  insecureRandomSource.getNode(), 
  "random value"