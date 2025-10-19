/**
 * @name Untrusted Input Injection via Cookies
 * @description Identifies instances where untrusted user inputs are directly used to construct cookie values,
 *              creating potential for injection attacks that could compromise session integrity and confidentiality.
 *              This pattern aligns with CWE-20 (Improper Input Validation) and may lead to cookie tampering vulnerabilities.
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
  int configId
where 
  configId = 1
  and CookieInjectionFlow::flowPath(untrustedInputSource, cookieAssignmentSink)
select 
  cookieAssignmentSink.getNode(), 
  untrustedInputSource, 
  cookieAssignmentSink, 
  "Cookie value constructed from $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"