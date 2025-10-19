/**
 * @name Untrusted Cookie Value Injection
 * @description Identifies security flaws where cookie values are directly constructed from user-controlled inputs,
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
  CookieInjectionFlow::PathNode untrustedInputOrigin, 
  CookieInjectionFlow::PathNode cookieValueSink, 
  int configurationIdentifier
where 
  configurationIdentifier = 1
  and CookieInjectionFlow::flowPath(untrustedInputOrigin, cookieValueSink)
select 
  cookieValueSink.getNode(), 
  untrustedInputOrigin, 
  cookieValueSink, 
  "Cookie value constructed from $@.", 
  untrustedInputOrigin.getNode(), 
  "untrusted user input"