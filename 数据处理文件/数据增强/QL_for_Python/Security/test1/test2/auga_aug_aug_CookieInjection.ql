/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies potential security vulnerabilities where untrusted user inputs 
 *              are used to construct cookie values, risking injection attacks.
 *              This query detects data flow paths from untrusted sources to cookie assignment points.
 * @id py/untrusted-cookie-injection
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 8.7
 * @tags security external/cwe/cwe-20
 * @note Filtered using configuration ID 1 for specific analysis context
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

/** 
 * Main query to find untrusted data flow to cookie construction
 */
from 
  CookieInjectionFlow::PathNode untrustedDataSource, 
  CookieInjectionFlow::PathNode cookieAssignmentTarget, 
  int configId
where 
  configId = 1 and
  CookieInjectionFlow::flowPath(untrustedDataSource, cookieAssignmentTarget)
select 
  cookieAssignmentTarget.getNode(), 
  untrustedDataSource, 
  cookieAssignmentTarget, 
  "Cookie value constructed from $@", 
  untrustedDataSource.getNode(), 
  "untrusted user input"