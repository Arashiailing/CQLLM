/**
 * @name Remote server command execution vulnerability
 * @description Identifies potential security risks where user-supplied data can lead to
 *              command execution on remote systems, potentially affecting other users
 *              or critical infrastructure components
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Import essential Python language support for security analysis
import python
// Import experimental functionality for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities to visualize and track data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Define variables representing the start and end points of the data flow
from RemoteCommandExecutionFlow::PathNode untrustedInputSource, RemoteCommandExecutionFlow::PathNode remoteCommandSink
// Ensure there is a complete data flow path from the untrusted source to the command execution sink
where RemoteCommandExecutionFlow::flowPath(untrustedInputSource, remoteCommandSink)
// Output the vulnerability details including the full propagation path
select remoteCommandSink.getNode(), untrustedInputSource, remoteCommandSink, 
       "This command execution originates from a $@.", untrustedInputSource.getNode(),
       "user-controlled input source"