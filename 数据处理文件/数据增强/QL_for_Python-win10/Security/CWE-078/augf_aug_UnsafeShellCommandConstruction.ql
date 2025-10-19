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

// Python language fundamentals
import python

// Module for detecting unsafe shell command construction vulnerabilities
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Path graph for tracking data flow between sources and sinks
import UnsafeShellCommandConstructionFlow::PathGraph

// Identify vulnerable command construction paths
from
  UnsafeShellCommandConstructionFlow::PathNode dataSource,  // External input source
  UnsafeShellCommandConstructionFlow::PathNode commandTarget, // Command execution point
  Sink executionDetail                                      // Detailed sink information
where
  // Ensure data flows from external input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(dataSource, commandTarget) and
  // Map flow node to detailed sink representation
  executionDetail = commandTarget.getNode()
select 
  // Vulnerability location: string construction details
  executionDetail.getStringConstruction(), 
  dataSource, 
  commandTarget,
  // Security context: input origin and command execution details
  "This " + executionDetail.describe() + 
  " which depends on $@ is later used in a $@.", 
  dataSource.getNode(), "library input", 
  executionDetail.getCommandExecution(), "shell command"