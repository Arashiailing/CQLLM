/**
 * @name Command execution on a secondary remote server
 * @description Identifies security vulnerabilities where user-supplied input
 *              can lead to arbitrary command execution on remote systems,
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

// Import core Python analysis capabilities
import python
// Import experimental module for remote command execution detection
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for data flow tracking
import RemoteCommandExecutionFlow::PathGraph

// Define tainted input sources and command execution sinks
from RemoteCommandExecutionFlow::PathNode taintedSource, RemoteCommandExecutionFlow::PathNode executionSink
// Validate data flow connection between source and sink
where RemoteCommandExecutionFlow::flowPath(taintedSource, executionSink)
// Generate security alert with vulnerability details
select executionSink.getNode(), taintedSource, executionSink, 
       "This code execution depends on a $@.", taintedSource.getNode(),
       "user-controlled input source"