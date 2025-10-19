/**
 * @name Cookie construction using externally controlled input
 * @description Creating cookies with attacker-controlled data enables Cookie Poisoning attacks,
 *              allowing adversaries to manipulate cookie values and circumvent security mechanisms.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis framework
import python

// Import specialized cookie injection vulnerability detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph visualization for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie construction
from 
  CookieInjectionFlow::PathNode untrustedSource, 
  CookieInjectionFlow::PathNode cookieSink
where 
  CookieInjectionFlow::flowPath(untrustedSource, cookieSink)
// Generate vulnerability report with source, sink, and flow path details
select 
  cookieSink.getNode(), 
  untrustedSource, 
  cookieSink, 
  "Cookie is constructed from a $@.", 
  untrustedSource.getNode(),
  "user-supplied input"