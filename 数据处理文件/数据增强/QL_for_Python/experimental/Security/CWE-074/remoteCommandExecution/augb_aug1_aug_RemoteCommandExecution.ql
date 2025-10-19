/**
 * @name Command execution on a secondary remote server
 * @description Detects when user-controlled input triggers command execution on external systems,
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

// Import essential Python language support for security analysis
import python
// Import experimental module specialized for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities to visualize and track data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Find data flow paths where tainted input reaches remote command execution points
from RemoteCommandExecutionFlow::PathNode taintedSource, RemoteCommandExecutionFlow::PathNode remoteCommandSink
// Ensure that there is a complete data flow propagation from the tainted source to the command sink
where RemoteCommandExecutionFlow::flowPath(taintedSource, remoteCommandSink)
// Generate vulnerability report with detailed propagation path information
select remoteCommandSink.getNode(), taintedSource, remoteCommandSink, 
       "This command execution originates from a $@.", taintedSource.getNode(),
       "user-controlled input source"