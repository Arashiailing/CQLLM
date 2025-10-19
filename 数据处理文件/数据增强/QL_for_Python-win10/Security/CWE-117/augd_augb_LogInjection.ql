/**
 * @name Log Injection Vulnerability
 * @description Detects when log entries are built using user-supplied input, 
 *              allowing attackers to inject malicious content and forge log entries.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Core Python analysis libraries
import python

// Taint tracking configuration for log injection analysis
import semmle.python.security.dataflow.LogInjectionQuery

// Path graph for visualizing vulnerability propagation paths
import LogInjectionFlow::PathGraph

from 
  LogInjectionFlow::PathNode maliciousInputSource,
  LogInjectionFlow::PathNode logSink
where 
  LogInjectionFlow::flowPath(maliciousInputSource, logSink)
select 
  logSink.getNode(), 
  maliciousInputSource, 
  logSink, 
  "This log entry depends on a $@.", 
  maliciousInputSource.getNode(),
  "user-provided value"