/**
 * @name Construction of a cookie using user-supplied input
 * @description Building cookies with user-provided data can lead to Cookie Poisoning attacks,
 *              where an attacker manipulates cookie values to bypass security controls.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import necessary modules for Python code analysis
import python

// Import the specialized module for detecting cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import the path graph representation to visualize data flow paths
import CookieInjectionFlow::PathGraph

// Identify flow paths from untrusted input sources to cookie construction points
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieCreationPoint
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieCreationPoint)
// Report the vulnerability with details about the source, sink, and flow path
select cookieCreationPoint.getNode(), untrustedInputSource, cookieCreationPoint, 
       "Cookie is constructed from a $@.", untrustedInputSource.getNode(),
       "user-supplied input"