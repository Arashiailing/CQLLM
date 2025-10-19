/**
 * @name Uncontrolled command line
 * @description Detects command execution vulnerabilities where external input
 *              can manipulate command behavior through injection attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// Import Python language support for code analysis
import python

// Import security dataflow framework for command injection detection
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph representation for vulnerability flow visualization
import CommandInjectionFlow::PathGraph

// Identify untrusted input sources and command execution sinks
from CommandInjectionFlow::PathNode maliciousInputSource, 
     CommandInjectionFlow::PathNode vulnerableCommandSink
// Validate data flow path exists between source and sink
where CommandInjectionFlow::flowPath(maliciousInputSource, vulnerableCommandSink)
// Report vulnerability with context about tainted input
select vulnerableCommandSink.getNode(), 
       maliciousInputSource, 
       vulnerableCommandSink, 
       "This command execution depends on a $@.", 
       maliciousInputSource.getNode(),
       "user-controlled input"