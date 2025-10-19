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

// Import core Python analysis capabilities
import python
// Import experimental module for remote command execution detection
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for data flow tracking
import RemoteCommandExecutionFlow::PathGraph

// Identify vulnerable data flows from user-controlled sources to remote command execution
from RemoteCommandExecutionFlow::PathNode taintedSource, RemoteCommandExecutionFlow::PathNode executionSink
where RemoteCommandExecutionFlow::flowPath(taintedSource, executionSink)
select executionSink.getNode(), taintedSource, executionSink, 
       "This code execution depends on a $@.", taintedSource.getNode(),
       "user-controlled input source"