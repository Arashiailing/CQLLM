/**
 * @name Log Injection
 * @description Attackers can forge log entries by injecting malicious content
 *              when log entries are constructed from user-controlled data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Import core Python analysis libraries
import python

// Import log injection taint tracking configuration
import semmle.python.security.dataflow.LogInjectionQuery

// Import path graph for vulnerability visualization
import LogInjectionFlow::PathGraph

// Identify log injection paths where tainted data reaches logging sinks
from LogInjectionFlow::PathNode taintedSource, LogInjectionFlow::PathNode loggingSink
where LogInjectionFlow::flowPath(taintedSource, loggingSink)
select loggingSink.getNode(), 
       taintedSource, 
       loggingSink, 
       "This log entry depends on a $@.", 
       taintedSource.getNode(),
       "user-provided value"