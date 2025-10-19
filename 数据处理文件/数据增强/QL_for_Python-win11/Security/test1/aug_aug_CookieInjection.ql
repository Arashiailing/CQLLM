/**
 * @name Construction of a cookie using user-supplied input
 * @description Building cookies with user-provided data can enable Cookie Poisoning attacks.
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

// Dataflow path visualization components
import CookieInjectionFlow::PathGraph

// Identify untrusted data flowing into cookie construction
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieConstructionSink
where CookieInjectionFlow::flowPath(untrustedSource, cookieConstructionSink)
// Report vulnerable cookie construction with tainted data flow
select cookieConstructionSink.getNode(), untrustedSource, cookieConstructionSink, 
       "Cookie built from $@.", untrustedSource.getNode(), "untrusted user input"