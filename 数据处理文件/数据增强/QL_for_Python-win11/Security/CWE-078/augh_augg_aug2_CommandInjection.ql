/**
 * @name Uncontrolled command line
 * @description Running commands with strings controlled by external sources can allow
 *              malicious actors to alter command execution, potentially compromising system security.
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

// Import core Python analysis library to enable fundamental code inspection
import python

// Import dedicated dataflow analysis module for detecting command injection vulnerabilities
import semmle.python.security.dataflow.CommandInjectionQuery

// Import graphical path representation module for tracking data flow trajectories
import CommandInjectionFlow::PathGraph

// Detect potential security flaws in command execution flows
from 
  CommandInjectionFlow::PathNode taintedInputNode,  // Entry point of untrusted data
  CommandInjectionFlow::PathNode dangerousSinkNode   // Point where command execution occurs
where 
  // Confirm that a complete data flow path connects the source to the sink
  CommandInjectionFlow::flowPath(taintedInputNode, dangerousSinkNode)
select 
  dangerousSinkNode.getNode(),                     // Location of the vulnerable command execution
  taintedInputNode,                                 // Origin node in the data flow
  dangerousSinkNode,                                // Destination node in the data flow
  "This command line depends on a $@.",             // Security vulnerability message
  taintedInputNode.getNode(),                       // Source code location reference
  "user-provided value"                             // Categorization of the source type