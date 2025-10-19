/**
 * @name Log Injection Vulnerability
 * @description Identifies security vulnerabilities where untrusted user inputs
 *              are directly written to logs without sanitization, potentially
 *              enabling log tampering, forgery, or injection attacks.
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

from LogInjectionFlow::PathNode maliciousSource, 
     LogInjectionFlow::PathNode vulnerableSink
where LogInjectionFlow::flowPath(maliciousSource, vulnerableSink)
select vulnerableSink.getNode(), 
       maliciousSource, 
       vulnerableSink,
       "This log entry incorporates a $@.", 
       maliciousSource.getNode(),
       "user-provided value"