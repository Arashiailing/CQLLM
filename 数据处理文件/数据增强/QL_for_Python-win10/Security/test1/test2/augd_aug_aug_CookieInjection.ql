/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies data flow paths where untrusted user input (e.g., HTTP request parameters)
 *              is used to construct cookie values. This could enable injection attacks that 
 *              compromise cookie integrity and lead to session hijacking or security bypasses.
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
  CookieInjectionFlow::PathNode cookieAssignmentSink, 
  int flowConfigurationId
where 
  flowConfigurationId = 1 and
  CookieInjectionFlow::flowPath(maliciousInputSource, cookieAssignmentSink)
select 
  cookieAssignmentSink.getNode(), 
  maliciousInputSource, 
  cookieAssignmentSink, 
  "Cookie value constructed from $@.", 
  maliciousInputSource.getNode(), 
  "untrusted user input"