/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Building cookies with data from untrusted origins enables injection attacks, 
 *              potentially compromising cookie security and integrity.
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

from CookieInjectionFlow::PathNode startNode, CookieInjectionFlow::PathNode endNode, int configurationId
where 
  configurationId = 1 and
  CookieInjectionFlow::flowPath(startNode, endNode)
select 
  endNode.getNode(), 
  startNode, 
  endNode, 
  "Cookie value constructed from $@.", 
  startNode.getNode(), 
  "untrusted user input"