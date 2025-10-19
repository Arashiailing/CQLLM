/**
 * @name Unsafe shell command constructed from library input
 * @description Building shell commands using external string inputs
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

// Security analysis for dangerous shell command construction
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Data flow path visualization framework
import UnsafeShellCommandConstructionFlow::PathGraph

// Identify vulnerable command construction flows
from
  Sink commandSink,                                         // Command execution details
  UnsafeShellCommandConstructionFlow::PathNode inputOrigin, // Untrusted input source
  UnsafeShellCommandConstructionFlow::PathNode executionPoint // Command execution point
where
  // Map execution point to detailed sink representation
  commandSink = executionPoint.getNode()
  and
  // Trace data flow from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputOrigin, executionPoint)
select 
  // Vulnerability context: string construction details
  commandSink.getStringConstruction(), 
  inputOrigin, 
  executionPoint,
  // Security impact: input source and command execution context
  "This " + commandSink.describe() + 
  " which depends on $@ is subsequently used in a $@.", 
  inputOrigin.getNode(), "library input", 
  commandSink.getCommandExecution(), "shell command"