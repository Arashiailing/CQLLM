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

// Define data flow tracking from untrusted sources to command sinks
from RemoteCommandExecutionFlow::PathNode taintedInput, RemoteCommandExecutionFlow::PathNode executionPoint
// Validate data flow path exists between input and execution
where RemoteCommandExecutionFlow::flowPath(taintedInput, executionPoint)
// Report results with vulnerability context
select executionPoint.getNode(), taintedInput, executionPoint, 
       "This code execution depends on a $@.", taintedInput.getNode(),
       "user-controlled input source"