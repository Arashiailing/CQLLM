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

// Import core Python analysis capabilities
import python
// Import experimental remote command execution detection framework
import experimental.semmle.python.security.RemoteCommandExecution
// Import path graph utilities for vulnerability tracking
import RemoteCommandExecutionFlow::PathGraph

// Locate untrusted data origins and command execution targets
from RemoteCommandExecutionFlow::PathNode untrustedInput, RemoteCommandExecutionFlow::PathNode executionSink
// Confirm a data flow path connects the untrusted input to the execution sink
where RemoteCommandExecutionFlow::flowPath(untrustedInput, executionSink)
// Report the vulnerability including context of the untrusted input and the execution sink
select executionSink.getNode(), untrustedInput, executionSink, 
       "This code execution depends on a $@.", untrustedInput.getNode(),
       "user-controlled input source"