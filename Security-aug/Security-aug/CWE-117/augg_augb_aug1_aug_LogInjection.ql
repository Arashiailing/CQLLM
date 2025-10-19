/**
 * @name Log Injection Vulnerability
 * @description Identifies security risks where untrusted user input is directly
 *              written to logs without sanitization, potentially enabling
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

from 
  LogInjectionFlow::PathNode taintedSource, 
  LogInjectionFlow::PathNode loggingSink
where 
  LogInjectionFlow::flowPath(taintedSource, loggingSink)
select 
  loggingSink.getNode(), 
  taintedSource, 
  loggingSink,
  "This log entry incorporates a $@.", 
  taintedSource.getNode(),
  "user-provided value"