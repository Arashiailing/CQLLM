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
 * Core analysis logic:
 * 1. Identify untrusted data sources
 * 2. Trace data flow to cookie assignment targets
 * 3. Apply configuration filter (ID=1)
 */
from 
  int configId,
  CookieInjectionFlow::PathNode untrustedSource,
  CookieInjectionFlow::PathNode cookieSink
where 
  configId = 1
  and CookieInjectionFlow::flowPath(untrustedSource, cookieSink)
select 
  cookieSink.getNode(), 
  untrustedSource, 
  cookieSink, 
  "Cookie value constructed from $@", 
  untrustedSource.getNode(), 
  "untrusted user input"