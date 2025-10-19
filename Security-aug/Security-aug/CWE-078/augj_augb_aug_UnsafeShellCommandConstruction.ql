/**
 * @name Unsafe shell command built from library input
 * @description Constructing shell commands from external input strings
 *              may result in command injection vulnerabilities.
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
  UnsafeShellCommandConstructionFlow::PathNode inputSource,    // External input source
  UnsafeShellCommandConstructionFlow::PathNode commandTarget,  // Command execution point
  Sink executionDetail                                          // Detailed execution context
where
  // Establish data flow connection from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputSource, commandTarget) and
  // Link flow node to its detailed execution context
  executionDetail = commandTarget.getNode()
select 
  // Location details: where the vulnerable string is constructed
  executionDetail.getStringConstruction(), 
  inputSource, 
  commandTarget,
  // Security context description: connecting input source to command execution
  "This " + executionDetail.describe() + 
  " which depends on $@ is subsequently used in a $@.", 
  inputSource.getNode(), "library input", 
  executionDetail.getCommandExecution(), "shell command"