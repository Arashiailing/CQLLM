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

// Core Python language support
import python
// Experimental analysis for remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for tracking data flow trajectories
import RemoteCommandExecutionFlow::PathGraph

// Identify vulnerable data flows from untrusted sources to command execution sinks
from RemoteCommandExecutionFlow::PathNode maliciousInput, RemoteCommandExecutionFlow::PathNode executionTarget
// Verify complete data flow path exists between input and execution point
where RemoteCommandExecutionFlow::flowPath(maliciousInput, executionTarget)
// Generate security alert with vulnerability context and flow details
select executionTarget.getNode(), maliciousInput, executionTarget, 
       "This command execution originates from $@.", maliciousInput.getNode(),
       "untrusted user input"