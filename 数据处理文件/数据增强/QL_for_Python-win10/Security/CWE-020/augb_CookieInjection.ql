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

// Identify vulnerable data flow paths from untrusted sources to cookie sinks
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieSink

// Verify existence of data flow path between source and sink
where CookieInjectionFlow::flowPath(untrustedSource, cookieSink)

// Report findings with vulnerability details
select cookieSink.getNode(), untrustedSource, cookieSink, "Cookie is constructed from a $@.", untrustedSource.getNode(),
  "user-supplied input"