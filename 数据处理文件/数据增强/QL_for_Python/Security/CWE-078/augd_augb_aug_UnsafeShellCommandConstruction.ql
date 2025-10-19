/**
 * @name Unsafe shell command constructed from library input
 * @description Building shell commands using strings from external sources
 *              can lead to command injection vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.3
 * @precision medium
 * @id py/shell-command-constructed-from-input
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 *       external/cwe/cwe-073
 */

// Core Python language support
import python

// Security analysis module for detecting unsafe shell command construction
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Path graph representation for tracking data flow
import UnsafeShellCommandConstructionFlow::PathGraph

// Define key components for vulnerability detection
from
  UnsafeShellCommandConstructionFlow::PathNode inputSourceNode,  // External input entry point
  UnsafeShellCommandConstructionFlow::PathNode commandSinkNode,   // Shell command execution point
  Sink executionDetails                                           // Detailed execution context
where
  // Establish complete data flow path from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputSourceNode, commandSinkNode) and
  // Map sink node to its detailed execution context
  executionDetails = commandSinkNode.getNode()
select 
  // Location where vulnerable string is constructed
  executionDetails.getStringConstruction(), 
  inputSourceNode, 
  commandSinkNode,
  // Security context description linking input to command execution
  "This " + executionDetails.describe() + 
  " which depends on $@ is subsequently used in a $@.", 
  inputSourceNode.getNode(), "library input", 
  executionDetails.getCommandExecution(), "shell command"