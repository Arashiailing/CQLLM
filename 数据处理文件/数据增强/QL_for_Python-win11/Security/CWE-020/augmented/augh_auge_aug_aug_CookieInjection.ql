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

// Core framework for Python code analysis
import python

// Security data flow module for detecting cookie injection
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph component for visualizing data flow tracks
import CookieInjectionFlow::PathGraph

// Identify data flow from untrusted input sources to cookie construction sinks
from CookieInjectionFlow::PathNode taintedSource, CookieInjectionFlow::PathNode vulnerableCookieBuilder
where CookieInjectionFlow::flowPath(taintedSource, vulnerableCookieBuilder)
// Report vulnerable cookie construction with source and flow path
select vulnerableCookieBuilder.getNode(), 
       taintedSource, 
       vulnerableCookieBuilder, 
       "Cookie is constructed from a $@.", 
       taintedSource.getNode(),
       "user-supplied input"