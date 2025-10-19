/**
 * @name Cookie construction from user-supplied input
 * @description Identifies cookie creation using untrusted user input,
 *              which could enable Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis library
import python

// Import dataflow tracking for cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path representation for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify untrusted sources and cookie construction sinks
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieSink
where CookieInjectionFlow::flowPath(untrustedSource, cookieSink)
// Report findings with security context
select cookieSink.getNode(), untrustedSource, cookieSink,
       "Cookie constructed from $@.", untrustedSource.getNode(),
       "untrusted user input"