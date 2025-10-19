/**
 * @name Log Injection
 * @description Detects potential log injection vulnerabilities where untrusted input
 *              is incorporated into log entries without sanitization, allowing attackers
 *              to forge or manipulate log content.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Core Python analysis modules
import python

// Taint tracking configuration for log injection detection
import semmle.python.security.dataflow.LogInjectionQuery

// Path graph generation for vulnerability flow visualization
import LogInjectionFlow::PathGraph

// Identify vulnerable paths where tainted data reaches logging mechanisms
from LogInjectionFlow::PathNode maliciousInputSource, 
     LogInjectionFlow::PathNode vulnerableLoggingSink
where 
  // Verify data flow exists between source and sink
  LogInjectionFlow::flowPath(maliciousInputSource, vulnerableLoggingSink)
select 
  // Primary vulnerability location
  vulnerableLoggingSink.getNode(), 
  // Flow path components
  maliciousInputSource, 
  vulnerableLoggingSink, 
  // Alert message with dynamic source reference
  "This log entry depends on a $@.", 
  maliciousInputSource.getNode(),
  "user-provided value"