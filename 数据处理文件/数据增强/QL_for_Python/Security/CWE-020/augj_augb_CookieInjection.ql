/**
 * @name Cookie construction with user-controlled input
 * @description Creating cookies using untrusted user input may enable Cookie Poisoning attacks,
 *              allowing attackers to manipulate cookie values.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis framework
import python

// Cookie injection vulnerability detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify vulnerable data flow paths
from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode
where CookieInjectionFlow::flowPath(sourceNode, sinkNode)

// Report vulnerability details with path information
select sinkNode.getNode(), sourceNode, sinkNode, "Cookie is constructed from a $@.", sourceNode.getNode(),
  "user-supplied input"