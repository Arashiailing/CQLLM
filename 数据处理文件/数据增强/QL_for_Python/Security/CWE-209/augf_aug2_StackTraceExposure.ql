/**
 * @name Exception information exposure
 * @description Revealing exception details (such as messages and stack traces) to external users 
 *              can expose internal implementation details, potentially aiding attackers in developing exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// Import core Python analysis library
import python

// Import specialized data flow analysis module for stack trace exposure
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import path visualization components for result presentation
import StackTraceExposureFlow::PathGraph

// Identify stack trace exposure paths from source to sink
from 
  StackTraceExposureFlow::PathNode exposureSource, 
  StackTraceExposureFlow::PathNode exposureSink
where 
  // Verify data flow path exists between source and sink
  StackTraceExposureFlow::flowPath(exposureSource, exposureSink)
select 
  exposureSink.getNode(), 
  exposureSource, 
  exposureSink,
  "$@ reaches this location and could be exposed to an external user.", 
  exposureSource.getNode(),
  "Stack trace information"