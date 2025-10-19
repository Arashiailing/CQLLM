/**
 * @name Insecure randomness
 * @description Detects when cryptographically weak pseudo-random number generators
 *              are used to generate security-sensitive values, potentially enabling
 *              attackers to predict the generated values.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import core Python analysis library
import python

// Import specialized security module for insecure randomness detection
import experimental.semmle.python.security.InsecureRandomness

// Import data flow tracking framework
import semmle.python.dataflow.new.DataFlow

// Import path graph representation for flow visualization
import InsecureRandomness::Flow::PathGraph

// Query definition: identifies data flow paths from insecure random sources to security-sensitive sinks
from 
  InsecureRandomness::Flow::PathNode sourceNode, 
  InsecureRandomness::Flow::PathNode sinkNode
where 
  // Verify existence of data flow path between source and sink
  InsecureRandomness::Flow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cryptographically insecure $@ in a security context.",
  sourceNode.getNode(), 
  "random value"