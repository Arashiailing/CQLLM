/**
 * @name XML external entity expansion vulnerability
 * @description Detects unsafe XML parsing where user-provided data
 *              is processed without protection against external entities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import core Python analysis capabilities
import python

// Import specialized XXE vulnerability detection components
import semmle.python.security.dataflow.XxeQuery

// Import path graph for visualizing data flow paths
import XxeFlow::PathGraph

// Identify vulnerable XML processing flows where tainted data reaches unsafe sinks
from XxeFlow::PathNode taintedInput, XxeFlow::PathNode vulnerableSink
where 
  // Verify data flows from user-controlled source to unsafe XML processor
  XxeFlow::flowPath(taintedInput, vulnerableSink)

// Generate vulnerability report with source-sink path
select vulnerableSink.getNode(), taintedInput, vulnerableSink,
  "XML parsing processes $@ without external entity expansion protection.",
  taintedInput.getNode(), "user-controlled input"