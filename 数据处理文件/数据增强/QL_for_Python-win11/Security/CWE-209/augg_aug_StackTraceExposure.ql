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

// Core Python analysis framework
import python

// Data flow analysis for stack trace exposure detection
import semmle.python.security.dataflow.StackTraceExposureQuery

// Path graph for vulnerability flow visualization
import StackTraceExposureFlow::PathGraph

// Identify vulnerable data flow paths
from 
  StackTraceExposureFlow::PathNode sourceNode, 
  StackTraceExposureFlow::PathNode sinkNode
where 
  // Verify data flow exists between source and sink
  StackTraceExposureFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  // Alert message with source context
  "$@ propagates to this location and could be exposed to an external user.", 
  sourceNode.getNode(),
  // Information type description
  "Stack trace details"