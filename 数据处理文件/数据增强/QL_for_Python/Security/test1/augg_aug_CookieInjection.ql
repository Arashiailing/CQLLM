/**
 * @name Construction of a cookie using user-supplied input
 * @description Building a cookie with user-provided input can enable an attacker to conduct a Cookie Poisoning attack.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis libraries
import python

// Import specialized cookie injection detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify vulnerable data flows from untrusted sources to cookie construction
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieConstructionSink
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieConstructionSink)
// Report results with sink node, source node, path context, and vulnerability description
select 
  cookieConstructionSink.getNode(),
  untrustedInputSource,
  cookieConstructionSink,
  "Cookie is constructed from a $@.",
  untrustedInputSource.getNode(),
  "user-supplied input"