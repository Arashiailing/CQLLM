/**
 * @name Cookie construction with user-controlled data
 * @description Detects potential Cookie Poisoning vulnerabilities where cookies are built using user-provided input
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis libraries
import python

// Cookie injection vulnerability detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph visualization for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie construction points
from 
  CookieInjectionFlow::PathNode untrustedSourceNode, 
  CookieInjectionFlow::PathNode cookieSinkNode
where 
  CookieInjectionFlow::flowPath(untrustedSourceNode, cookieSinkNode)
// Output vulnerability details: sink location, source location, path, message, and source classification
select 
  cookieSinkNode.getNode(), 
  untrustedSourceNode, 
  cookieSinkNode, 
  "Cookie is constructed from a $@.", 
  untrustedSourceNode.getNode(),
  "user-supplied input"