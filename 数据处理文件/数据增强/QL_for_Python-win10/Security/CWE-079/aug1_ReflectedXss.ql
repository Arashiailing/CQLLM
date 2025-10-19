/**
 * @name Reflected server-side cross-site scripting
 * @description Detects vulnerabilities where user input is directly
 *              written to web pages without sanitization, enabling
 *              cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/reflective-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Core Python analysis libraries
import python
// Specialized module for detecting reflected XSS vulnerabilities
import semmle.python.security.dataflow.ReflectedXssQuery
// Path visualization component for data flow analysis
import ReflectedXssFlow::PathGraph

// Identify vulnerable data flow paths from user input to output
from ReflectedXssFlow::PathNode origin, ReflectedXssFlow::PathNode destination
// Verify existence of complete data flow path between origin and destination
where ReflectedXssFlow::flowPath(origin, destination)
// Report vulnerability with path details and contextual information
select destination.getNode(), origin, destination, "Cross-site scripting vulnerability due to a $@.",
  origin.getNode(), "user-provided value"