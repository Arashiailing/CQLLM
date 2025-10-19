/**
 * @name Insecure randomness
 * @description Identifies security risks when cryptographically weak pseudo-random number 
 *              generators are used in security-sensitive contexts, potentially enabling 
 *              attackers to predict values and compromise system security.
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

// Import experimental security module for detecting insecure random number generation patterns
import experimental.semmle.python.security.InsecureRandomness

// Import data flow analysis framework to enable tracking of data flow paths
import semmle.python.dataflow.new.DataFlow

// Import path graph module for representing data flow path graphs
import InsecureRandomness::Flow::PathGraph

// Define source and sink variables for our analysis
from 
  InsecureRandomness::Flow::PathNode insecureSource,  // Node representing insecure random value generation
  InsecureRandomness::Flow::PathNode securitySink      // Node representing security-sensitive usage

// Verify existence of data flow path from insecure source to security sink
where 
  InsecureRandomness::Flow::flowPath(insecureSource, securitySink)

// Generate results with path information and alert message
select 
  securitySink.getNode(),                            // Target node where the insecure value is used
  insecureSource,                                    // Source node where the insecure value originates
  securitySink,                                      // Sink node for path visualization
  "Cryptographically insecure $@ in a security context.", // Alert message
  insecureSource.getNode(),                          // Source node for message reference
  "random value"                                     // Description of the insecure element