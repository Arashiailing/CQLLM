/**
 * @name Command execution on a secondary remote server
 * @description Identifies scenarios where user-supplied data propagates to command execution
 *              interfaces on external systems, creating risks of lateral movement or
 *              infrastructure compromise
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Core Python language support for security analysis
import python
// Specialized module for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for tracking data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Identify data flow paths where untrusted input reaches remote command execution points
from RemoteCommandExecutionFlow::PathNode untrustedSource,
     RemoteCommandExecutionFlow::PathNode commandExecutionSink
where 
  // Verify complete data flow propagation from source to sink
  RemoteCommandExecutionFlow::flowPath(untrustedSource, commandExecutionSink)
select 
  commandExecutionSink.getNode(), 
  untrustedSource, 
  commandExecutionSink,
  "This command execution originates from a $@.", 
  untrustedSource.getNode(),
  "user-controlled input source"