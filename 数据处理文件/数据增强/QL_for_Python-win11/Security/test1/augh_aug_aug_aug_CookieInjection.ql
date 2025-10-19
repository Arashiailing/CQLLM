/**
 * @name Cookie construction from user-supplied input
 * @description Detects cookie creation using untrusted user input,
 *              potentially enabling Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis library
import python

// Import dataflow tracking for cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path representation for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify untrusted input sources and cookie construction sinks
from CookieInjectionFlow::PathNode untrustedInputNode, CookieInjectionFlow::PathNode cookieCreationNode
// Establish data flow connection between source and sink
where CookieInjectionFlow::flowPath(untrustedInputNode, cookieCreationNode)
// Report findings with security context
select cookieCreationNode.getNode(), untrustedInputNode, cookieCreationNode,
       "Cookie constructed from $@.", untrustedInputNode.getNode(),
       "untrusted user input"