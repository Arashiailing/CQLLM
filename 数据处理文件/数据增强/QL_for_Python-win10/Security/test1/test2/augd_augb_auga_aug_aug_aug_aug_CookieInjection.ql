/**
 * @name Untrusted Cookie Value Injection
 * @description Identifies security vulnerabilities where untrusted user inputs directly 
 *              influence cookie values without proper sanitization. This can lead to 
 *              session hijacking, data tampering, or authentication bypass. The pattern 
 *              violates CWE-20 (Improper Input Validation) and exposes systems to 
 *              cookie-based attacks.
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
  CookieInjectionFlow::PathNode untrustedInputSource, 
  CookieInjectionFlow::PathNode cookieAssignmentSink, 
  int configurationId
where 
  configurationId = 1
  and CookieInjectionFlow::flowPath(untrustedInputSource, cookieAssignmentSink)
select 
  cookieAssignmentSink.getNode(), 
  untrustedInputSource, 
  cookieAssignmentSink, 
  "Cookie value constructed from $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"