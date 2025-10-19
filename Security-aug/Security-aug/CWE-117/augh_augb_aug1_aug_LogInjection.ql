/**
 * @name Log Injection Vulnerability
 * @description Identifies security risks where untrusted user inputs are directly
 *              logged without sanitization, enabling log tampering or injection attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode untrustedSource, LogInjectionFlow::PathNode loggingSink
where 
  exists(LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink |
    source = untrustedSource and
    sink = loggingSink and
    LogInjectionFlow::flowPath(source, sink)
  )
select loggingSink.getNode(), untrustedSource, loggingSink,
       "This log entry incorporates a $@.", untrustedSource.getNode(),
       "user-provided value"