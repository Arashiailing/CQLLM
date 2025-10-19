/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user inputs are propagated
 *              into cookie value assignments, potentially enabling injection
 *              attacks that compromise cookie integrity.
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
  CookieInjectionFlow::PathNode untrustedSourceNode, 
  CookieInjectionFlow::PathNode cookieSinkNode
where 
  CookieInjectionFlow::flowPath(untrustedSourceNode, cookieSinkNode)
select 
  cookieSinkNode.getNode(), 
  untrustedSourceNode, 
  cookieSinkNode, 
  "Cookie value constructed from $@.", 
  untrustedSourceNode.getNode(), 
  "untrusted user input"