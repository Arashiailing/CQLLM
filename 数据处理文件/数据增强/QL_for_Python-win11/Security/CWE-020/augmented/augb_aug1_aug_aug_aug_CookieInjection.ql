/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects security vulnerabilities where untrusted user input flows 
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
  CookieInjectionFlow::PathNode userInputSource, 
  CookieInjectionFlow::PathNode cookieAssignmentSink
where 
  CookieInjectionFlow::flowPath(userInputSource, cookieAssignmentSink)
select 
  cookieAssignmentSink.getNode(), 
  userInputSource, 
  cookieAssignmentSink, 
  "Cookie value constructed from $@.", 
  userInputSource.getNode(), 
  "untrusted user input"