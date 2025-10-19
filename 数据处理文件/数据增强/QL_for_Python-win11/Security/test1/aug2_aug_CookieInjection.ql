/**
 * @name Cookie creation using untrusted user input
 * @description Building cookies from external input may enable attackers to perform Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python analysis libraries
import python

// Import specialized Cookie Injection analysis modules
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie construction sinks
from CookieInjectionFlow::PathNode untrustedInputNode, CookieInjectionFlow::PathNode cookieConstructionNode
where CookieInjectionFlow::flowPath(untrustedInputNode, cookieConstructionNode)
// Output results including sink location, source location, path details, and vulnerability description
select cookieConstructionNode.getNode(), untrustedInputNode, cookieConstructionNode, "Cookie is constructed from a $@.", untrustedInputNode.getNode(),
  "user-supplied input"