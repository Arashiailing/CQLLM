/**
 * @name Command execution on a secondary remote server
 * @description Identifies vulnerabilities where user-supplied data can trigger 
 *              command execution on remote systems, potentially leading to 
 *              compromise of other systems or administrative infrastructure
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
// Experimental module for detecting remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for tracking data flow propagation paths
import RemoteCommandExecutionFlow::PathGraph

// Define source and sink nodes for tracking data flow
from RemoteCommandExecutionFlow::PathNode userInputSource, RemoteCommandExecutionFlow::PathNode execSinkPoint
// Verify that a complete data flow path exists from source to sink
where RemoteCommandExecutionFlow::flowPath(userInputSource, execSinkPoint)
// Generate vulnerability report with detailed propagation path information
select execSinkPoint.getNode(), userInputSource, execSinkPoint, 
       "This command execution originates from a $@.", userInputSource.getNode(),
       "user-controlled input source"