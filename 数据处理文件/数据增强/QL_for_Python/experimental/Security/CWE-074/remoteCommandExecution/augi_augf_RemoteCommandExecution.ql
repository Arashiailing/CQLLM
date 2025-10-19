/**
 * @name Command execution on a secondary remote server
 * @description User-provided command can lead to code execution on an external server 
 *              that may belong to other users or administrators
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Core Python language support
import python
// Security analysis module for remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph representation for taint flow analysis
import RemoteCommandExecutionFlow::PathGraph

// Identify security-relevant data flow paths from user input to command execution
from RemoteCommandExecutionFlow::PathNode userInputSource, RemoteCommandExecutionFlow::PathNode commandExecutionSink
where RemoteCommandExecutionFlow::flowPath(userInputSource, commandExecutionSink)
// Generate alert with vulnerability path and contextual details
select commandExecutionSink.getNode(), 
       userInputSource, 
       commandExecutionSink, 
       "This code execution depends on a $@.", 
       userInputSource.getNode(), 
       "user-provided value"