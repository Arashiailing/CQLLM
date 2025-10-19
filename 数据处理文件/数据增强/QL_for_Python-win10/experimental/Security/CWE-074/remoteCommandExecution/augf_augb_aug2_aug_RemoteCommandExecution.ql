/**
 * @name Command execution on a secondary remote server
 * @description Identifies data flow paths from user-provided inputs to remote command execution,
 *              potentially enabling compromise of external systems or privileged credentials
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Core Python analysis framework import
import python
// Experimental security analysis for remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path visualization utilities for data flow tracking
import RemoteCommandExecutionFlow::PathGraph

// Identify data flows from uncontrolled inputs to remote execution points
from RemoteCommandExecutionFlow::PathNode taintedOrigin, RemoteCommandExecutionFlow::PathNode commandSink
// Verify complete data flow path exists between input source and execution sink
where RemoteCommandExecutionFlow::flowPath(taintedOrigin, commandSink)
// Report vulnerability with execution point and its source
select commandSink.getNode(), taintedOrigin, commandSink, 
       "This code execution depends on a $@.", taintedOrigin.getNode(),
       "user-controlled input source"