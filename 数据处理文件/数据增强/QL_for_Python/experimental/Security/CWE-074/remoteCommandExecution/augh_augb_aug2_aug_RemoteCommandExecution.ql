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

// Import fundamental Python analysis features
import python
// Import experimental module for remote command execution vulnerability analysis
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for data flow path visualization
import RemoteCommandExecutionFlow::PathGraph

// Identify data flows from user-controlled inputs to remote command execution sinks
from 
  RemoteCommandExecutionFlow::PathNode userControlledInputSource,
  RemoteCommandExecutionFlow::PathNode remoteExecSink
// Verify that a complete data flow path exists from the input source to the execution sink
where 
  RemoteCommandExecutionFlow::flowPath(userControlledInputSource, remoteExecSink)
// Produce an alert highlighting the vulnerable execution point and its source
select 
  remoteExecSink.getNode(), 
  userControlledInputSource, 
  remoteExecSink, 
  "This code execution depends on a $@.", 
  userControlledInputSource.getNode(), 
  "user-controlled input source"