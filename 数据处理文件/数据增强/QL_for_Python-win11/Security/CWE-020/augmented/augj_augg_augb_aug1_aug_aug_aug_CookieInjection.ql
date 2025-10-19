/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects security vulnerabilities where untrusted user input 
 *              flows into cookie value assignments. This can enable 
 *              injection attacks that compromise cookie integrity and security.
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
  CookieInjectionFlow::PathNode maliciousInputSource,
  CookieInjectionFlow::PathNode cookieAssignmentSink
where 
  CookieInjectionFlow::flowPath(maliciousInputSource, cookieAssignmentSink)
select 
  cookieAssignmentSink.getNode(), 
  maliciousInputSource, 
  cookieAssignmentSink, 
  "Cookie value constructed from $@.", 
  maliciousInputSource.getNode(), 
  "untrusted user input"