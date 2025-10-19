/**
 * @name Cookie construction with user-controlled data
 * @description Building cookies using user-provided input could lead to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python libraries for code analysis
import python

// Import query module for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify untrusted input sources flowing into cookie creation sites
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieCreationSink
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieCreationSink)
// Output results: sink location, source location, path, message, and source type
select cookieCreationSink.getNode(), untrustedInputSource, cookieCreationSink, "Cookie is constructed from a $@.", untrustedInputSource.getNode(),
  "user-supplied input"