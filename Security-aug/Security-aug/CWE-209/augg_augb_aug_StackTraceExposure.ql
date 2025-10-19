/**
 * @name Information exposure through an exception
 * @description Detects potential leakage of exception information (messages and stack traces) 
 *              to unauthorized users, which may disclose system internals that attackers 
 *              could leverage to develop further attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// Import required Python analysis capabilities
import python

// Import module for analyzing stack trace information exposure
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import path graph utilities for visualizing data flows
import StackTraceExposureFlow::PathGraph

// Find paths where stack trace information flows from source to sink
from StackTraceExposureFlow::PathNode startPointNode, StackTraceExposureFlow::PathNode endPointNode
where StackTraceExposureFlow::flowPath(startPointNode, endPointNode)
select 
  endPointNode.getNode(), // Primary location to report
  startPointNode, endPointNode, // Path context for visualization
  "$@ propagates to this location and could be exposed to an external user.", startPointNode.getNode(), // Flow description
  "Stack trace details" // Type of sensitive information