/**
 * @name Log Injection Vulnerability
 * @description Identifies log entries constructed with untrusted user input, 
 *              enabling attackers to inject malicious content and forge log entries.
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
  LogInjectionFlow::PathNode taintedSource,
  LogInjectionFlow::PathNode vulnerableSink
where 
  LogInjectionFlow::flowPath(taintedSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  taintedSource, 
  vulnerableSink, 
  "This log entry depends on a $@.", 
  taintedSource.getNode(),
  "user-provided value"