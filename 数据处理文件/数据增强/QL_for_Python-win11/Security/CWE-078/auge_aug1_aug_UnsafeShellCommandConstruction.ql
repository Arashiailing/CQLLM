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
  UnsafeShellCommandConstructionFlow::PathNode inputOrigin,  // External input source
  UnsafeShellCommandConstructionFlow::PathNode commandSink,   // Command execution point
  Sink executionDetail                                       // Detailed sink information
where
  // Map flow node to detailed sink representation
  executionDetail = commandSink.getNode()
  and
  // Verify data flow from external input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputOrigin, commandSink)
select 
  // Vulnerability location: string construction details
  executionDetail.getStringConstruction(), 
  inputOrigin, 
  commandSink,
  // Security context: input origin and command execution details
  "This " + executionDetail.describe() + 
  " which depends on $@ is later used in a $@.", 
  inputOrigin.getNode(), "library input", 
  executionDetail.getCommandExecution(), "shell command"