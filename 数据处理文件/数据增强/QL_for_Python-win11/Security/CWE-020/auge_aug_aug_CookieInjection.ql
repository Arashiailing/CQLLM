/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects security vulnerabilities where untrusted data sources 
 *              are used to construct HTTP cookies, enabling injection attacks
 *              that compromise cookie integrity and security.
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
  configId = 1 and
  CookieInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie value constructed from $@.", 
  sourceNode.getNode(), 
  "untrusted user input"