/**
 * @name Command execution on a secondary remote server
 * @description Detects when user-supplied data flows to remote command execution,
 *              which could lead to compromise of other systems or privileged accounts
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
// Import experimental module for analyzing remote command execution vulnerabilities
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for visualizing data flow paths
import RemoteCommandExecutionFlow::PathGraph

// Find data flows from user-controlled inputs to remote command execution points
from RemoteCommandExecutionFlow::PathNode userInputSource, RemoteCommandExecutionFlow::PathNode execSink
// Ensure there exists a complete data flow path between the input source and execution sink
where RemoteCommandExecutionFlow::flowPath(userInputSource, execSink)
// Generate alert showing the vulnerable execution point and its source
select execSink.getNode(), userInputSource, execSink, 
       "This code execution depends on a $@.", userInputSource.getNode(),
       "user-controlled input source"