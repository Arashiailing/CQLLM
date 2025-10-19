/**
 * @name Command execution on a secondary remote server
 * @description Detects user-controlled inputs that lead to command execution on external systems,
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

// Core Python language support for security analysis
import python
// Experimental utilities for identifying remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph components for tracking data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Identify vulnerable paths where untrusted input reaches remote command execution points
from RemoteCommandExecutionFlow::PathNode untrustedSource, RemoteCommandExecutionFlow::PathNode commandExecutionSink
// Verify complete data flow propagation from untrusted source to command execution sink
where RemoteCommandExecutionFlow::flowPath(untrustedSource, commandExecutionSink)
// Generate vulnerability report with detailed propagation path information
select commandExecutionSink.getNode(), untrustedSource, commandExecutionSink, 
       "This command execution originates from a $@.", untrustedSource.getNode(),
       "user-controlled input source"