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
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode, 
  int configurationId
where 
  configurationId = 1
  and CookieInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie value constructed from $@.", 
  sourceNode.getNode(), 
  "untrusted user input"