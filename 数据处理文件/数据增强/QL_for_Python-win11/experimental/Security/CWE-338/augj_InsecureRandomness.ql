/**
 * @name Insecure randomness
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for security-sensitive values, which could enable attackers to predict
 *              the generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import Python library for analyzing Python code
import python

// Import experimental module for detecting insecure random number generation
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis module for tracking data flow paths
import semmle.python.dataflow.new.DataFlow

// Import path graph representation for data flow paths
import InsecureRandomness::Flow::PathGraph

// Define the main query to find insecure randomness path problems
from InsecureRandomness::Flow::PathNode startPoint, InsecureRandomness::Flow::PathNode endPoint
where 
  // Condition: there exists a data flow path from source to sink
  InsecureRandomness::Flow::flowPath(startPoint, endPoint)
select 
  // Output format: sink node, source node, sink node, message, source node, and description
  endPoint.getNode(), 
  startPoint, 
  endPoint, 
  "Cryptographically insecure $@ in a security context.",
  startPoint.getNode(), 
  "random value"