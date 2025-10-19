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

// Security analysis module for shell command injection detection
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Data flow path tracking infrastructure
import UnsafeShellCommandConstructionFlow::PathGraph

// Identify vulnerable command construction patterns
from
  UnsafeShellCommandConstructionFlow::PathNode inputSource,    // External input origin
  UnsafeShellCommandConstructionFlow::PathNode executionSink,   // Command execution point
  Sink sinkInfo                                                // Detailed sink metadata
where
  // Verify data flow path from input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(inputSource, executionSink) and
  // Map execution node to sink details
  sinkInfo = executionSink.getNode()
select 
  // Vulnerability context: string construction details
  sinkInfo.getStringConstruction(), 
  inputSource, 
  executionSink,
  // Security impact description with contextual placeholders
  "This " + sinkInfo.describe() + 
  " which depends on $@ is later used in a $@.", 
  inputSource.getNode(), "library input", 
  sinkInfo.getCommandExecution(), "shell command"