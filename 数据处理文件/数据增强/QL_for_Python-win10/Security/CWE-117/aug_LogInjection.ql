/**
 * @name Log Injection Vulnerability
 * @description Detects potential log injection issues where untrusted user input
 *              is incorporated into log entries without proper sanitization,
 *              allowing attackers to forge or manipulate log content.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Import Python code analysis library for parsing and processing Python source code
import python

// Import security data flow module specifically for detecting log injection vulnerabilities
import semmle.python.security.dataflow.LogInjectionQuery

// Import the path graph class from the log injection data flow module
import LogInjectionFlow::PathGraph

// Define a query to identify potential log injection paths through the code
from LogInjectionFlow::PathNode origin, LogInjectionFlow::PathNode destination
where LogInjectionFlow::flowPath(origin, destination)
// Select the vulnerable log entry, its data flow source and sink, along with descriptive message
select destination.getNode(), origin, destination, 
       "This log entry incorporates a $@.", origin.getNode(), 
       "user-provided value"