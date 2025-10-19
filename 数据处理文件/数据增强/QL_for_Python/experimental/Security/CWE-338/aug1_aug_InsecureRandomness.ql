/**
 * @name Insecure randomness
 * @description Detects security vulnerabilities where cryptographically weak 
 *              pseudo-random number generators are used to generate security-sensitive values,
 *              potentially allowing attackers to predict generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python library for code analysis support
import python

// Import experimental security module specialized in detecting insecure random number generation patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis framework to enable tracking of data flow paths
import semmle.python.dataflow.new.DataFlow

// Import path graph module for representing data flow path graphs
import InsecureRandomness::Flow::PathGraph

// Query definition: Identify data flow paths involving insecure random number generation
from InsecureRandomness::Flow::PathNode sourceNode, InsecureRandomness::Flow::PathNode sinkNode
// Define the data flow condition between source and sink nodes
where InsecureRandomness::Flow::flowPath(sourceNode, sinkNode)
// Select results with the sink node, source node, path information, and descriptive message
select sinkNode.getNode(), sourceNode, sinkNode, "Cryptographically insecure $@ in a security context.",
  sourceNode.getNode(), "random value"