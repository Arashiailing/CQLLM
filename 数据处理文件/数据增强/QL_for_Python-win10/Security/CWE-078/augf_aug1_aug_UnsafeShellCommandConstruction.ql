/**
 * @name Unsafe shell command constructed from library input
 * @description Building shell commands using externally controlled strings
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

// Security analysis module for unsafe shell command construction
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Path graph representation for data flow tracking
import UnsafeShellCommandConstructionFlow::PathGraph

// Identify vulnerable command construction paths
from
  UnsafeShellCommandConstructionFlow::PathNode inputSource,  // External input source
  UnsafeShellCommandConstructionFlow::PathNode commandSink,  // Command execution point
  Sink sinkDetail                                           // Detailed sink information
where
  // Establish data flow from external input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputSource, commandSink)
  and
  // Map flow node to detailed sink representation
  sinkDetail = commandSink.getNode()
select 
  // Vulnerability location: string construction details
  sinkDetail.getStringConstruction(), 
  inputSource, 
  commandSink,
  // Security context: input origin and command execution details
  "This " + sinkDetail.describe() + 
  " which depends on $@ is later used in a $@.", 
  inputSource.getNode(), "library input", 
  sinkDetail.getCommandExecution(), "shell command"