/**
 * @name Construction of a cookie using user-supplied input
 * @description Building cookies using untrusted user-provided data could lead to a Cookie Poisoning attack, enabling an attacker to manipulate cookie values.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python libraries for code analysis
import python

// Import specialized module for detecting cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to vulnerable cookie constructions
from CookieInjectionFlow::PathNode maliciousInput, CookieInjectionFlow::PathNode vulnerableCookie
where CookieInjectionFlow::flowPath(maliciousInput, vulnerableCookie)

// Generate security alert with vulnerability details
select vulnerableCookie.getNode(), 
       maliciousInput, 
       vulnerableCookie, 
       "Cookie is constructed from a $@.", 
       maliciousInput.getNode(), 
       "user-supplied input"