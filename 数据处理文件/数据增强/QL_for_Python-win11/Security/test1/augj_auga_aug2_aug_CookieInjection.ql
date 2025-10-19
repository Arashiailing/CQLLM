/**
 * @name Untrusted Input to Cookie Construction Vulnerability
 * @description Constructing HTTP cookies with untrusted user input enables cookie poisoning attacks 
 *              where an attacker can manipulate session tokens or other sensitive data.
 * @kind path-problem
 * @problem.severity warning
 * @precision medium
 * @security-severity 6.0
 * @id py/untrusted-cookie-source
 * @tags security
 *        external/cwe/cwe-20
 *        external/cwe/cwe-79
 */

// Import core Python analysis libraries
import python

// Import specialized cookie injection analysis components
import semmle.python.security.dataflow.CookieInjectionQuery

// Import data flow tracking framework for path analysis
import CookieInjectionFlow::PathGraph

// Identify untrusted input sources flowing into cookie construction points
from CookieInjectionFlow::PathNode userInputSource, CookieInjectionFlow::PathNode cookieCreationPoint
where CookieInjectionFlow::flowPath(userInputSource, cookieCreationPoint)

// Generate vulnerability report with flow path details
select cookieCreationPoint.getNode(), 
       userInputSource, 
       cookieCreationPoint, 
       "Cookie is constructed from a $@", 
       userInputSource.getNode(), 
       "user-supplied input",
       "This pattern allows attackers to inject malicious content into HTTP cookies,"
       + " potentially compromising session integrity and user privacy."