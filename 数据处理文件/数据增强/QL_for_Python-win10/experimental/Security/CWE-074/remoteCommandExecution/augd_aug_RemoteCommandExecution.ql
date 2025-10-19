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

// Import core Python language support for analysis
import python
// Import specialized module for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities to visualize data flow trajectories
import RemoteCommandExecutionFlow::PathGraph

// Identify vulnerable data flows from untrusted sources to command execution sinks
from RemoteCommandExecutionFlow::PathNode untrustedSource, RemoteCommandExecutionFlow::PathNode commandSink
where RemoteCommandExecutionFlow::flowPath(untrustedSource, commandSink)
// Generate security alert with complete flow context
select commandSink.getNode(), untrustedSource, commandSink, 
       "This code execution depends on a $@.", untrustedSource.getNode(),
       "user-controlled input source"