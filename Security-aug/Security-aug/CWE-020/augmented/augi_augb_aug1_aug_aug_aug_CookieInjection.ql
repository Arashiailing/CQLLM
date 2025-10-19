/**
 * @name Untrusted Input Flow to Cookie Value Assignment
 * @description Identifies security risks where untrusted external input reaches 
 *              cookie value assignments, potentially enabling injection attacks 
 *              that undermine cookie integrity and security mechanisms.
 * @id py/untrusted-cookie-injection
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 8.7
 * @tags security external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

from 
  CookieInjectionFlow::PathNode untrustedInputOrigin, 
  CookieInjectionFlow::PathNode cookieValueTarget
where 
  CookieInjectionFlow::flowPath(untrustedInputOrigin, cookieValueTarget)
select 
  cookieValueTarget.getNode(), 
  untrustedInputOrigin, 
  cookieValueTarget, 
  "Cookie value constructed from $@.", 
  untrustedInputOrigin.getNode(), 
  "untrusted user input"