/**
 * @name Command execution on a secondary remote server
 * @description Identifies user-controlled inputs that trigger command execution on external systems,
 *              potentially compromising other users or administrative infrastructure
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Import core Python language support for security analysis
import python
// Import experimental module for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities to track and visualize data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Identify data flow paths where untrusted input reaches remote command execution points
from RemoteCommandExecutionFlow::PathNode untrustedInputSource, RemoteCommandExecutionFlow::PathNode remoteExecutionSink
// Verify complete data flow propagation from untrusted source to command execution sink
where RemoteCommandExecutionFlow::flowPath(untrustedInputSource, remoteExecutionSink)
// Generate vulnerability report with detailed propagation path information
select remoteExecutionSink.getNode(), untrustedInputSource, remoteExecutionSink, 
       "This command execution originates from a $@.", untrustedInputSource.getNode(),
       "user-controlled input source"