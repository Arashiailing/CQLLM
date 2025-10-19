/**
 * @name Untrusted Data Flow to Cookie Value Assignment
 * @description Detects data flow paths from untrusted user inputs to cookie value assignments,
 *              which could lead to injection attacks compromising cookie integrity.
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
  CookieInjectionFlow::PathNode taintedSourceNode,
  CookieInjectionFlow::PathNode cookieSinkNode
where 
  CookieInjectionFlow::flowPath(taintedSourceNode, cookieSinkNode)
select 
  cookieSinkNode.getNode(), 
  taintedSourceNode, 
  cookieSinkNode, 
  "Cookie value constructed from $@.", 
  taintedSourceNode.getNode(), 
  "untrusted user input"