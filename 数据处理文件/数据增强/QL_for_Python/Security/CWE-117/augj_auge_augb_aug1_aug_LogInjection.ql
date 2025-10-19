/**
 * @name Log Injection Vulnerability
 * @description Detects security flaws where untrusted user inputs
 *              are directly logged without sanitization, enabling
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

from LogInjectionFlow::PathNode taintedSource,
     LogInjectionFlow::PathNode vulnerableSink
where 
  LogInjectionFlow::flowPath(taintedSource, vulnerableSink)
select 
  vulnerableSink.getNode(),
  taintedSource,
  vulnerableSink,
  "This log entry incorporates a $@.",
  taintedSource.getNode(),
  "user-provided value"