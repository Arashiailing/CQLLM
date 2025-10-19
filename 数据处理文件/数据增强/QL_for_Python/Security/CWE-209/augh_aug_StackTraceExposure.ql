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

// Import core Python analysis capabilities
import python

// Import specialized data flow tracking module for stack trace vulnerabilities
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import path graph components for vulnerability visualization
import StackTraceExposureFlow::PathGraph

// Identify data flow paths where stack trace information reaches external exposure points
from 
  StackTraceExposureFlow::PathNode sourceNode, 
  StackTraceExposureFlow::PathNode sinkNode
where 
  // Verify existence of complete data flow path from source to sink
  StackTraceExposureFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  // Message template describing the vulnerability propagation
  "$@ propagates to this location and could be exposed to an external user.", 
  sourceNode.getNode(), 
  // Type of sensitive information being tracked
  "Stack trace details"