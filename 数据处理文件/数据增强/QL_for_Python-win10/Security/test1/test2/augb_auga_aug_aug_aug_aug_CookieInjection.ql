/**
 * @name Untrusted Cookie Value Injection
 * @description Detects vulnerabilities where user-controlled inputs directly influence cookie values,
 *              potentially enabling session hijacking or data tampering. This pattern violates
 *              CWE-20 (Improper Input Validation) and exposes systems to cookie-based attacks.
 * @id py/untrusted-cookie-injection
 * @kind path-problem
 * @precision medium
 * @problem.severity high
 * @security-severity 8.7
 * @tags security external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

from 
  CookieInjectionFlow::PathNode maliciousInputSource, 
  CookieInjectionFlow::PathNode vulnerableCookieSink, 
  int flowConfigId
where 
  flowConfigId = 1
  and CookieInjectionFlow::flowPath(maliciousInputSource, vulnerableCookieSink)
select 
  vulnerableCookieSink.getNode(), 
  maliciousInputSource, 
  vulnerableCookieSink, 
  "Cookie value constructed from $@.", 
  maliciousInputSource.getNode(), 
  "untrusted user input"