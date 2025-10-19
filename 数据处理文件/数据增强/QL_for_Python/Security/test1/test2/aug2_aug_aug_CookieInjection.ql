/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies data flow paths where untrusted user input reaches cookie assignments,
 *              potentially enabling injection attacks that compromise cookie integrity.
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
  CookieInjectionFlow::PathNode cookieAssignment
where 
  exists(int configId | 
    configId = 1 and 
    CookieInjectionFlow::flowPath(taintedSource, cookieAssignment)
  )
select 
  cookieAssignment.getNode(), 
  taintedSource, 
  cookieAssignment, 
  "Cookie value constructed from $@.", 
  taintedSource.getNode(), 
  "untrusted user input"