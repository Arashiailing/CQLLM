/**
 * @name Construction of a cookie using user-supplied input
 * @description Constructing cookies from user input may allow an attacker to perform a Cookie Poisoning attack.
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

// Cookie injection security analysis module
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted input sources to cookie construction sinks
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieConstructionSink
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieConstructionSink)
// Report results with sink node, source node, path details, and vulnerability description
select cookieConstructionSink.getNode(), untrustedInputSource, cookieConstructionSink, 
       "Cookie is constructed from a $@.", untrustedInputSource.getNode(), "user-supplied input"