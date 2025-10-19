/**
 * @name Secondary server command execution vulnerability
 * @description Detects when user-supplied data can lead to arbitrary command execution
 *              on remote systems, potentially enabling lateral movement or privilege escalation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Import core Python analysis framework
import python
// Import experimental module for remote code execution detection
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for data flow visualization
import RemoteCommandExecutionFlow::PathGraph

// Identify data flow paths from untrusted sources to command execution sinks
from RemoteCommandExecutionFlow::PathNode untrustedSource, RemoteCommandExecutionFlow::PathNode commandSink
// Ensure a complete data flow path exists between source and sink
where RemoteCommandExecutionFlow::flowPath(untrustedSource, commandSink)
// Generate vulnerability report with source tracking
select commandSink.getNode(), untrustedSource, commandSink, 
       "This command execution is influenced by $@.", untrustedSource.getNode(),
       "untrusted user input"