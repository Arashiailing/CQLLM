/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects security vulnerabilities where cookies are constructed using untrusted input,
 *              enabling injection attacks that compromise cookie security and integrity.
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
  CookieInjectionFlow::PathNode taintedSource, 
  CookieInjectionFlow::PathNode cookieSink, 
  int configurationId
where 
  configurationId = 1
  and CookieInjectionFlow::flowPath(taintedSource, cookieSink)
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  taintedSource.getNode(), 
  "untrusted user input"