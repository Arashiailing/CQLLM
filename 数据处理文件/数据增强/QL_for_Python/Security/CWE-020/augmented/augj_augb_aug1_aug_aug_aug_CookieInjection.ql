/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies security vulnerabilities where untrusted user input flows 
 *              into cookie value assignments, potentially enabling injection attacks 
 *              that compromise cookie integrity and security.
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
  CookieInjectionFlow::PathNode untrustedInput, 
  CookieInjectionFlow::PathNode cookieSink
where 
  CookieInjectionFlow::flowPath(untrustedInput, cookieSink)
select 
  cookieSink.getNode(), 
  untrustedInput, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  untrustedInput.getNode(), 
  "untrusted user input"