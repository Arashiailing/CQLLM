/**
 * @name Log Injection Vulnerability
 * @description This query identifies log injection vulnerabilities by detecting when 
 *              untrusted user input is included in log messages without sanitization, 
 *              which could allow attackers to forge log entries or manipulate log content.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Import the Python analysis library for source code parsing and processing
import python

// Import the security data flow module for log injection vulnerability detection
import semmle.python.security.dataflow.LogInjectionQuery

// Import the path graph class for log injection flow analysis
import LogInjectionFlow::PathGraph

// Query for detecting log injection data flow paths
from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where 
  // Verify data flows from untrusted source to logging sink
  LogInjectionFlow::flowPath(source, sink)
// Select vulnerable log entry with flow path and source description
select sink.getNode(), source, sink, 
       "This log entry incorporates a $@.", source.getNode(), 
       "user-provided value"