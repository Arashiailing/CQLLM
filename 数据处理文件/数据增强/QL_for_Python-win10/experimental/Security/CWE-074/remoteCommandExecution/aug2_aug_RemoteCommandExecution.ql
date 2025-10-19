/**
 * @name Command execution on a secondary remote server
 * @description User-controlled input can trigger command execution on external servers,
 *              potentially compromising other users or administrative systems
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Import required libraries for security analysis
import python
// Import experimental remote command execution analysis module
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph class for tracking data flows
import RemoteCommandExecutionFlow::PathGraph

// Identify untrusted input sources and command execution sinks
from RemoteCommandExecutionFlow::PathNode untrustedSource, RemoteCommandExecutionFlow::PathNode commandSink
// Verify data flow path exists between source and sink
where RemoteCommandExecutionFlow::flowPath(untrustedSource, commandSink)
// Report vulnerability with source and sink context
select commandSink.getNode(), untrustedSource, commandSink, 
       "This code execution depends on a $@.", untrustedSource.getNode(),
       "user-controlled input source"