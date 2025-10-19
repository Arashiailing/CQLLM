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

// Identify vulnerable paths where external input flows to shell commands
from
  UnsafeShellCommandConstructionFlow::PathNode sourceNode,    // External input source
  UnsafeShellCommandConstructionFlow::PathNode targetNode,    // Command execution point
  Sink executionContext                                       // Detailed execution context
where
  // Establish data flow connection from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(sourceNode, targetNode) and
  // Link flow node to its detailed execution context
  executionContext = targetNode.getNode()
select 
  // Location details: where the vulnerable string is constructed
  executionContext.getStringConstruction(), 
  sourceNode, 
  targetNode,
  // Security context description: connecting input source to command execution
  "This " + executionContext.describe() + 
  " which depends on $@ is subsequently used in a $@.", 
  sourceNode.getNode(), "library input", 
  executionContext.getCommandExecution(), "shell command"