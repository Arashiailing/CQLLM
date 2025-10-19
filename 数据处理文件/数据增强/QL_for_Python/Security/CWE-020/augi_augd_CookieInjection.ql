/**
 * @name Cookie constructed from user-controlled data
 * @description Creating cookies with data provided by the user can lead to Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

// Identify data flow paths where user-controlled input reaches cookie construction
from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode
where CookieInjectionFlow::flowPath(sourceNode, sinkNode)
// Output the sink node, source node, path details, and vulnerability description
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "Cookie is constructed from a $@.", 
       sourceNode.getNode(), 
       "user-supplied input"