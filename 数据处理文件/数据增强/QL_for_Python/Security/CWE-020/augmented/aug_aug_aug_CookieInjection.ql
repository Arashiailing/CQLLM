/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies data flow paths where untrusted user input reaches cookie value assignments,
 *              potentially leading to injection attacks that compromise cookie integrity.
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
  CookieInjectionFlow::PathNode untrustedInputNode, 
  CookieInjectionFlow::PathNode cookieAssignmentNode
where 
  exists(int configId | 
    configId = 1 and 
    CookieInjectionFlow::flowPath(untrustedInputNode, cookieAssignmentNode)
  )
select 
  cookieAssignmentNode.getNode(), 
  untrustedInputNode, 
  cookieAssignmentNode, 
  "Cookie value constructed from $@.", 
  untrustedInputNode.getNode(), 
  "untrusted user input"