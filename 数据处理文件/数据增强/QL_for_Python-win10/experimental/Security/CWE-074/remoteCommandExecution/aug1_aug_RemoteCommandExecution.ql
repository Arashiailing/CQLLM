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

// Core Python language support for security analysis
import python
// Experimental module for remote command execution vulnerability detection
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for tracking data flow propagation
import RemoteCommandExecutionFlow::PathGraph

// Identify data flow paths from untrusted sources to command execution sinks
from RemoteCommandExecutionFlow::PathNode untrustedSource, RemoteCommandExecutionFlow::PathNode commandSink
// Verify complete data flow propagation exists between source and sink
where RemoteCommandExecutionFlow::flowPath(untrustedSource, commandSink)
// Generate vulnerability report with propagation path details
select commandSink.getNode(), untrustedSource, commandSink, 
       "This command execution originates from a $@.", untrustedSource.getNode(),
       "user-controlled input source"