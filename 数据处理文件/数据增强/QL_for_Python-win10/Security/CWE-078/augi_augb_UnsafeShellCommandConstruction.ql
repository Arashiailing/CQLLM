/**
 * @name Unsafe shell command constructed from library input
 * @description Detects security vulnerabilities where shell commands are built using 
 *              externally controlled input, potentially enabling command injection attacks.
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

// Import Python language support and security analysis modules
import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph

// Define the data flow analysis tracking from external input to shell command execution
from
  UnsafeShellCommandConstructionFlow::PathNode sourceNode,  // Origin point representing external input
  UnsafeShellCommandConstructionFlow::PathNode sinkNode,    // Target point where command is executed
  Sink sinkInfo                                             // Detailed information about the sink
where
  // Establish the relationship between the sink node and its detailed representation
  sinkInfo = sinkNode.getNode()
  and
  // Verify the existence of a data flow path from source to sink
  UnsafeShellCommandConstructionFlow::flowPath(sourceNode, sinkNode)
select 
  // Report the string construction details along with the flow path endpoints
  sinkInfo.getStringConstruction(), sourceNode, sinkNode,
  // Generate contextual vulnerability description message
  "This " + sinkInfo.describe() + " which depends on $@ is later used in a $@.", 
  sourceNode.getNode(), "library input", 
  sinkInfo.getCommandExecution(), "shell command"