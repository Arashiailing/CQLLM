/**
 * @name Cookie construction from user-controlled data
 * @description Building cookies with user-provided data can enable Cookie Poisoning attacks,
 *              where malicious input manipulates cookie values to compromise application security.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python analysis framework
import python

// Import security module for detecting cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow analysis
import CookieInjectionFlow::PathGraph

// Define source and sink nodes for cookie injection analysis
from CookieInjectionFlow::PathNode userControlledSource, CookieInjectionFlow::PathNode cookieCreationSink
// Check if data flows from user input to cookie construction
where CookieInjectionFlow::flowPath(userControlledSource, cookieCreationSink)
// Report the vulnerability with detailed information
select 
  cookieCreationSink.getNode(), 
  userControlledSource, 
  cookieCreationSink, 
  "Cookie is constructed from a $@.", 
  userControlledSource.getNode(),
  "user-controlled input"