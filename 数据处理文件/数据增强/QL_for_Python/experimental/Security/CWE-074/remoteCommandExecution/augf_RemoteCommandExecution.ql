/**
 * @name Command execution on a secondary remote server
 * @description User-provided command can lead to code execution on an external server 
 *              that may belong to other users or administrators
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Core Python language support
import python
// Security analysis module for remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph representation for taint flow analysis
import RemoteCommandExecutionFlow::PathGraph

// Define taint flow endpoints: source (user input) and sink (command execution)
from RemoteCommandExecutionFlow::PathNode taintedInput, RemoteCommandExecutionFlow::PathNode executionPoint
// Establish taint flow relationship between input and execution
where RemoteCommandExecutionFlow::flowPath(taintedInput, executionPoint)
// Generate security alert with contextual information
select executionPoint.getNode(), taintedInput, executionPoint, 
       "This code execution depends on a $@.", 
       taintedInput.getNode(), 
       "user-provided value"