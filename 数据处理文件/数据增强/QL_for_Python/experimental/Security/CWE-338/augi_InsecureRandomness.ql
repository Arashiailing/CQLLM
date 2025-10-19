/**
 * @name Insecure randomness
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for generating security-sensitive values, which could enable attackers
 *              to predict the generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import Python library for Python code analysis
import python

// Import experimental module for detecting insecure random number generation
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis module for tracking data flow paths
import semmle.python.dataflow.new.DataFlow

// Import path graph representation for insecure randomness flow
import InsecureRandomness::Flow::PathGraph

// Define query to identify path problems related to insecure random number generation
from InsecureRandomness::Flow::PathNode insecureRandomSource, InsecureRandomness::Flow::PathNode securitySensitiveSink
where 
  // Condition: there exists a data flow path from source to sink
  InsecureRandomness::Flow::flowPath(insecureRandomSource, securitySensitiveSink)
select 
  // Output: sink node, source node, path information, and description
  securitySensitiveSink.getNode(), 
  insecureRandomSource, 
  securitySensitiveSink, 
  "Cryptographically insecure $@ in a security context.",
  insecureRandomSource.getNode(), 
  "random value"