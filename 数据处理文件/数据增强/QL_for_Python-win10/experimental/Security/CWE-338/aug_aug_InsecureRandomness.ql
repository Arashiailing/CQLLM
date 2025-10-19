/**
 * @name Insecure randomness
 * @description Detects the use of cryptographically weak pseudo-random number generators
 *              for security-sensitive operations, which could allow attackers to predict
 *              generated values and compromise system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// Import Python core library to enable Python code analysis capabilities
import python

// Import experimental security module specifically designed for detecting
// insecure random number generation patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis framework to enable tracking of data flow paths
import semmle.python.dataflow.new.DataFlow

// Import path graph module for representing data flow path graphs
import InsecureRandomness::Flow::PathGraph

// Query definition: Identify data flow paths involving insecure random number generation
from 
  InsecureRandomness::Flow::PathNode sourceNode,  // Source node representing the insecure random value generation
  InsecureRandomness::Flow::PathNode sinkNode      // Sink node representing security-sensitive usage
where 
  // Condition: Verify there exists a data flow path from source to sink
  InsecureRandomness::Flow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(),                              // Target node where the insecure value is used
  sourceNode,                                      // Source node where the insecure value originates
  sinkNode,                                       // Sink node for path visualization
  "Cryptographically insecure $@ in a security context.", // Alert message
  sourceNode.getNode(),                           // Source node for message reference
  "random value"                                  // Description of the insecure element