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

// Core imports for Python analysis
import python

// Cookie injection data flow analysis module
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Define data flow sources (user input) and sinks (cookie construction)
from CookieInjectionFlow::PathNode taintedInput, CookieInjectionFlow::PathNode cookieSink

// Ensure data flows from user input to cookie construction
where CookieInjectionFlow::flowPath(taintedInput, cookieSink)

// Output results with vulnerability details
select 
  cookieSink.getNode(),           // Vulnerable cookie construction location
  taintedInput,                   // Source of user input
  cookieSink,                     // Sink in data flow path
  "Cookie is constructed from a $@.", // Alert message template
  taintedInput.getNode(),         // User input source location
  "user-supplied input"           // Source description