/**
 * @name Log Injection Vulnerability
 * @description Identifies log injection vulnerabilities where untrusted input
 *              is logged without sanitization, enabling log tampering or forgery.
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

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
       "This log entry incorporates a $@.", source.getNode(),
       "user-provided value"