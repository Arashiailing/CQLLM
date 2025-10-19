/**
 * @name Unsafe shell command constructed from library input
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
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

// Import Python language support
import python

// Import security analysis module for unsafe shell command construction
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// Import path graph representation for data flow tracking
import UnsafeShellCommandConstructionFlow::PathGraph

// Define data flow path analysis between external input and command execution
from
  UnsafeShellCommandConstructionFlow::PathNode origin,      // External input source point
  UnsafeShellCommandConstructionFlow::PathNode destination, // Command execution sink point
  Sink destinationDetail                                   // Detailed sink information
where
  // Establish data flow connection between source and sink
  destinationDetail = destination.getNode() and
  UnsafeShellCommandConstructionFlow::flowPath(origin, destination)
select 
  // Output string construction details and flow path nodes
  destinationDetail.getStringConstruction(), origin, destination,
  // Generate vulnerability description message
  "This " + destinationDetail.describe() + " which depends on $@ is later used in a $@.", 
  origin.getNode(), "library input", 
  destinationDetail.getCommandExecution(), "shell command"