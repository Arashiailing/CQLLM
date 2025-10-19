/**
 * @name Reflected server-side cross-site scripting
 * @description Detects vulnerabilities where user-controlled input is directly
 *              written to a web page without proper sanitization, enabling
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

// Import Python language library for code analysis
import python
// Import specialized module for reflected cross-site scripting vulnerability detection
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph module for representing data flow paths visually
import ReflectedXssFlow::PathGraph

// Define the main query to detect reflected XSS vulnerabilities
from ReflectedXssFlow::PathNode userInputSource, ReflectedXssFlow::PathNode xssVulnerableSink
// Ensure there exists a data flow path from the user input source to the XSS-vulnerable sink
where ReflectedXssFlow::flowPath(userInputSource, xssVulnerableSink)
// Select the vulnerable sink, source node, path information, and generate descriptive message
select xssVulnerableSink.getNode(), userInputSource, xssVulnerableSink, 
       "Cross-site scripting vulnerability due to a $@.",
       userInputSource.getNode(), "user-provided value"