/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Constructing cookies using data from untrusted sources enables injection attacks,
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

from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode, int configId
where 
  configId = 1
  and CookieInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie value constructed from $@.", 
  sourceNode.getNode(), 
  "untrusted user input"