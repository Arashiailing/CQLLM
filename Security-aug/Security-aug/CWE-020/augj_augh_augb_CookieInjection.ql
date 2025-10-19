/**
 * @name Cookie construction using untrusted input
 * @description Building cookies with user-provided data enables Cookie Poisoning attacks,
 *              allowing attackers to manipulate cookie values.
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

// Import specialized data flow tracking for cookie injection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph for vulnerability flow visualization
import CookieInjectionFlow::PathGraph

// Define data flow components: untrusted input source and cookie construction sink
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieSink

// Verify data flow path exists between untrusted input and cookie construction
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieSink)

// Generate alert with vulnerability details and flow path
select cookieSink.getNode(), untrustedInputSource, cookieSink,
       "Cookie is constructed from a $@.", untrustedInputSource.getNode(),
       "user-supplied input"