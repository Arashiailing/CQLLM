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
  UnsafeShellCommandConstructionFlow::PathNode sourceNode, // External input source
  UnsafeShellCommandConstructionFlow::PathNode sinkNode,    // Command execution point
  Sink sinkInfo                                            // Detailed sink information
where
  // Verify data flow from external input to command execution
  UnsafeShellCommandConstructionFlow::flowPath(sourceNode, sinkNode)
  and
  // Map flow node to detailed sink representation
  sinkInfo = sinkNode.getNode()
select 
  // Vulnerability location: string construction details
  sinkInfo.getStringConstruction(), 
  sourceNode, 
  sinkNode,
  // Security context: input origin and command execution details
  "This " + sinkInfo.describe() + 
  " which depends on $@ is later used in a $@.", 
  sourceNode.getNode(), "library input", 
  sinkInfo.getCommandExecution(), "shell command"