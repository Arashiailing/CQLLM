/**
 * @name Secondary Remote Server Command Execution
 * @description Identifies instances where user-provided data reaches a remote command execution point,
 *              potentially leading to compromise of other systems or privileged accounts.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

import python
import experimental.semmle.python.security.RemoteCommandExecution
import RemoteCommandExecutionFlow::PathGraph

// Define source and sink nodes for remote command execution data flow
from 
  RemoteCommandExecutionFlow::PathNode source,     // Represents user-controlled input entry point
  RemoteCommandExecutionFlow::PathNode sink        // Represents remote command execution point
// Verify complete data flow path exists from source to sink
where 
  RemoteCommandExecutionFlow::flowPath(source, sink)
// Generate alert with vulnerability details
select 
  sink.getNode(),                                  // Vulnerable execution point
  source,                                          // Input source node
  sink,                                            // Sink node
  "This code execution depends on a $@.",           // Alert message template
  source.getNode(),                                // Source node reference
  "user-controlled input source"                   // Source description