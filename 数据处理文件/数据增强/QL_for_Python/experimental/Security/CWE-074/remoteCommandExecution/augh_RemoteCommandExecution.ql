/**
 * @name Secondary Remote Server Command Execution
 * @description User-controlled input can lead to arbitrary code execution on external servers,
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

// Import Python language support
import python
// Import experimental security analysis for remote command execution
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for taint tracking visualization
import RemoteCommandExecutionFlow::PathGraph

// Define taint flow source and sink nodes
from RemoteCommandExecutionFlow::PathNode userInput, 
     RemoteCommandExecutionFlow::PathNode executionPoint
// Verify complete taint propagation path exists
where RemoteCommandExecutionFlow::flowPath(userInput, executionPoint)
// Generate security alert with execution context details
select executionPoint.getNode(), 
       userInput, 
       executionPoint, 
       "This code execution depends on a $@.", 
       userInput.getNode(), 
       "a user-provided value"