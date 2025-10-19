/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies security vulnerabilities where untrusted user input 
 *              propagates into cookie value assignments. This can lead to 
 *              injection attacks compromising cookie integrity and security.
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
  CookieInjectionFlow::PathNode untrustedDataSource,
  CookieInjectionFlow::PathNode cookieValueSink
where 
  CookieInjectionFlow::flowPath(untrustedDataSource, cookieValueSink)
select 
  cookieValueSink.getNode(), 
  untrustedDataSource, 
  cookieValueSink, 
  "Cookie value constructed from $@.", 
  untrustedDataSource.getNode(), 
  "untrusted user input"