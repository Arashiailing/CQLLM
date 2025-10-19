/**
 * @name Uncontrolled command line
 * @description Execution of commands with externally controlled strings can enable
 *              attackers to manipulate command behavior, leading to potential system compromise.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// Import Python analysis core library for fundamental code analysis capabilities
import python

// Import specialized command injection dataflow analysis module
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path visualization module for data flow tracking
import CommandInjectionFlow::PathGraph

// Identify vulnerable command execution paths
from 
  CommandInjectionFlow::PathNode sourceNode,  // Origin of untrusted data
  CommandInjectionFlow::PathNode sinkNode     // Destination where command executes
where 
  // Verify complete data flow path exists from source to sink
  CommandInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(),                          // Vulnerable command execution point
  sourceNode,                                  // Data flow source node
  sinkNode,                                    // Data flow sink node
  "This command line depends on a $@.",        // Vulnerability description
  sourceNode.getNode(),                        // Source code location
  "user-provided value"                        // Source type classification