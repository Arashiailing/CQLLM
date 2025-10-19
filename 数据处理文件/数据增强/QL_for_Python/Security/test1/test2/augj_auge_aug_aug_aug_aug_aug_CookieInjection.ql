/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies data flow paths where untrusted user input propagates into cookie value assignments,
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
  CookieInjectionFlow::PathNode untrustedInputNode, 
  CookieInjectionFlow::PathNode cookieSinkNode, 
  int configId
where 
  configId = 1
  and CookieInjectionFlow::flowPath(untrustedInputNode, cookieSinkNode)
select 
  cookieSinkNode.getNode(), 
  untrustedInputNode, 
  cookieSinkNode, 
  "Cookie value constructed from $@.", 
  untrustedInputNode.getNode(), 
  "untrusted user input"