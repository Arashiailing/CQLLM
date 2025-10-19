/**
 * @name Log Injection Vulnerability
 * @description Detects security flaws where untrusted user input is directly
 *              written to logs without proper sanitization, potentially enabling
 *              log tampering, forgery, or injection attacks.
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

from LogInjectionFlow::PathNode untrustedInput, LogInjectionFlow::PathNode logSink
where LogInjectionFlow::flowPath(untrustedInput, logSink)
select logSink.getNode(), untrustedInput, logSink,
       "This log entry incorporates a $@.", untrustedInput.getNode(),
       "user-provided value"