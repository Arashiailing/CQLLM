/**
 * @name Cookie constructed from user input
 * @description Constructing cookies with user-controlled data can lead to Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

// Identify untrusted input source and cookie construction point
from 
  CookieInjectionFlow::PathNode untrustedInput,    // Origin of user-controlled data
  CookieInjectionFlow::PathNode cookieConstruction  // Location where cookie is built
// Verify data flow path exists between source and sink
where CookieInjectionFlow::flowPath(untrustedInput, cookieConstruction)
// Report findings with path details
select 
  cookieConstruction.getNode(), 
  untrustedInput, 
  cookieConstruction, 
  "Cookie is constructed from a $@.", 
  untrustedInput.getNode(),
  "user-supplied input"