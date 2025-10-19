/**
 * @name Information exposure through an exception
 * @description Detects potential exposure of exception details (messages and stack traces) 
 *              to external users, which could reveal implementation details useful to attackers
 *              for crafting subsequent exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// Import Python library for code analysis
import python

// Import custom module for analyzing stack trace exposure via data flow
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import PathGraph class from the StackTraceExposureFlow namespace
import StackTraceExposureFlow::PathGraph

// Identify paths where stack trace information might be exposed to external users
from StackTraceExposureFlow::PathNode startPoint, StackTraceExposureFlow::PathNode endPoint
where StackTraceExposureFlow::flowPath(startPoint, endPoint) // Condition: a path exists from source to sink
select endPoint.getNode(), startPoint, endPoint, // Select the sink node, source node, and sink node
  "$@ propagates to this location and could be exposed to an external user.", startPoint.getNode(), // Message: information flows here and might be exposed
  "Stack trace details" // Description of the information type