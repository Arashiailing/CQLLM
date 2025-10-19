/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects security vulnerabilities where untrusted user inputs 
 *              flow into cookie value assignments, enabling injection attacks.
 *              This query identifies data flow paths from untrusted sources 
 *              to cookie construction points.
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
 * Identifies paths where untrusted data flows into cookie assignments
 * using configuration ID 1 for targeted analysis
 */
from 
  CookieInjectionFlow::PathNode untrustedSource, 
  CookieInjectionFlow::PathNode cookieTarget, 
  int configurationId
where 
  configurationId = 1 and
  CookieInjectionFlow::flowPath(untrustedSource, cookieTarget)
select 
  cookieTarget.getNode(), 
  untrustedSource, 
  cookieTarget, 
  "Cookie value constructed from $@", 
  untrustedSource.getNode(), 
  "untrusted user input"