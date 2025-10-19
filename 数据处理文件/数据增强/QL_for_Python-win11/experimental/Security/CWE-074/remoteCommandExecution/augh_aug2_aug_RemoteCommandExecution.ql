/**
 * @name Secondary server command execution vulnerability
 * @description Detects when user-controlled input flows to remote command execution,
 *              potentially compromising external systems or administrative interfaces
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// Core analysis imports for Python security scanning
import python
// Specialized module for remote command execution detection
import experimental.semmle.python.security.RemoteCommandExecution
// Path graph utilities for taint flow tracking
import RemoteCommandExecutionFlow::PathGraph

// Identify malicious input sources and remote command execution sinks
from RemoteCommandExecutionFlow::PathNode maliciousInputSource, 
     RemoteCommandExecutionFlow::PathNode remoteCommandSink
// Validate complete data flow path between source and sink
where RemoteCommandExecutionFlow::flowPath(maliciousInputSource, remoteCommandSink)
// Generate vulnerability report with source/sink context
select remoteCommandSink.getNode(), maliciousInputSource, remoteCommandSink, 
       "This remote command execution originates from $@.", maliciousInputSource.getNode(),
       "untrusted user input"