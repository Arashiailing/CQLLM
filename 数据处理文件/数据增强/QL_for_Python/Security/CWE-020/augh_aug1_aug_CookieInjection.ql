/**
 * @name Cookie Construction from Untrusted Input
 * @description Identifies when cookies are created using user-provided data,
 *              potentially leading to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis libraries
import python

// Specialized module for detecting Cookie Injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization utilities for data flow analysis
import CookieInjectionFlow::PathGraph

// Identify untrusted input sources and cookie creation points
from CookieInjectionFlow::PathNode untrustedInputOrigin, 
     CookieInjectionFlow::PathNode cookieCreationTarget

// Validate data flow path exists between untrusted input and cookie creation
where CookieInjectionFlow::flowPath(untrustedInputOrigin, cookieCreationTarget)

// Generate security alert with vulnerability details and flow path
select cookieCreationTarget.getNode(), 
       untrustedInputOrigin, 
       cookieCreationTarget, 
       "Cookie is constructed from a $@.", 
       untrustedInputOrigin.getNode(), 
       "user-supplied input"