/**
 * @name Command execution on a secondary remote server
 * @description Identifies vulnerabilities where external input reaches remote command execution,
 *              potentially enabling unauthorized system access or privilege escalation
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
// Import experimental module for detecting remote command execution risks
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for tracking data flow trajectories
import RemoteCommandExecutionFlow::PathGraph

// Identify data flow paths from untrusted inputs to remote command execution points
from RemoteCommandExecutionFlow::PathNode sourceNode, RemoteCommandExecutionFlow::PathNode sinkNode
// Verify complete data flow propagation exists between input source and execution sink
where RemoteCommandExecutionFlow::flowPath(sourceNode, sinkNode)
// Report vulnerability with execution point and its input origin
select sinkNode.getNode(), sourceNode, sinkNode, 
       "This code execution originates from a $@.", sourceNode.getNode(),
       "user-controlled input source"