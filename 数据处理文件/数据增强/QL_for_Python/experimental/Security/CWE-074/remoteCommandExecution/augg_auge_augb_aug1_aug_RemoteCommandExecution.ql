/**
 * @name Remote command execution via external server
 * @description Detects when user-provided input flows to command execution
 *              interfaces on remote systems, potentially enabling lateral movement
 *              or infrastructure compromise
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Fundamental Python language support for security analysis
import python
// Specialized module for identifying remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for tracing data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Detect data flow paths where untrusted input reaches remote command execution points
from RemoteCommandExecutionFlow::PathNode userInputSource,
     RemoteCommandExecutionFlow::PathNode remoteCommandSink
where 
  // Ensure complete data flow propagation from source to sink
  RemoteCommandExecutionFlow::flowPath(userInputSource, remoteCommandSink)
select 
  remoteCommandSink.getNode(), 
  userInputSource, 
  remoteCommandSink,
  "This command execution originates from a $@.", 
  userInputSource.getNode(),
  "user-controlled input source"