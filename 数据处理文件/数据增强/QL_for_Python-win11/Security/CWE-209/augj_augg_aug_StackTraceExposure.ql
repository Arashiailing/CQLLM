/**
 * @name Information exposure through an exception
 * @description Identifies code paths where exception details (messages and stack traces) 
 *              may be exposed to external users. Such exposure risks revealing implementation 
 *              details that attackers could leverage to craft subsequent exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// Core Python analysis framework
import python

// Data flow analysis for stack trace exposure detection
import semmle.python.security.dataflow.StackTraceExposureQuery

// Path graph for vulnerability flow visualization
import StackTraceExposureFlow::PathGraph

// Identify vulnerable data flow paths
from 
  StackTraceExposureFlow::PathNode vulnerableSource, 
  StackTraceExposureFlow::PathNode exposureSink
where 
  // Verify data flow exists between source and sink
  StackTraceExposureFlow::flowPath(vulnerableSource, exposureSink)
select 
  exposureSink.getNode(), 
  vulnerableSource, 
  exposureSink,
  // Alert message with source context
  "$@ propagates to this location and could be exposed to an external user.", 
  vulnerableSource.getNode(),
  // Information type description
  "Stack trace details"