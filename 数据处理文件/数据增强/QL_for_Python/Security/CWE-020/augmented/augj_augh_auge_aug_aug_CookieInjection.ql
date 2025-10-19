/**
 * @name Cookie construction from untrusted user input
 * @description Constructing cookies using user-provided data can lead to cookie poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core framework for Python code analysis
import python

// Import security data flow module for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph component for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify data flow from untrusted sources to cookie construction sinks
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieSink
where CookieInjectionFlow::flowPath(untrustedSource, cookieSink)
// Report vulnerable cookie construction with source and flow path
select cookieSink.getNode(), 
       untrustedSource, 
       cookieSink, 
       "Cookie is constructed from a $@.", 
       untrustedSource.getNode(),
       "user-supplied input"