/**
 * @name Unsafe shell command constructed from library input
 * @description Constructing shell commands from externally controlled strings
 *              may enable command injection attacks.
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

// Security analysis module for unsafe shell command construction
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Path graph representation for data flow tracking
import UnsafeShellCommandConstructionFlow::PathGraph

// Identify vulnerable command construction paths
from
  // External input source node in data flow path
  UnsafeShellCommandConstructionFlow::PathNode inputSourceNode,
  // Command execution sink node in data flow path
  UnsafeShellCommandConstructionFlow::PathNode executionSinkNode,
  // Detailed sink metadata object
  Sink sinkDetails
where
  // Verify complete data flow path from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputSourceNode, executionSinkNode)
  and
  // Map sink node to detailed sink representation
  sinkDetails = executionSinkNode.getNode()
select 
  // Vulnerability location: string construction details
  sinkDetails.getStringConstruction(), 
  inputSourceNode, 
  executionSinkNode,
  // Security context: input origin and command execution details
  "This " + sinkDetails.describe() + 
  " which depends on $@ is later used in a $@.", 
  inputSourceNode.getNode(), "library input", 
  sinkDetails.getCommandExecution(), "shell command"