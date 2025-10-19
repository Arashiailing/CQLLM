/**
 * @name Exception information exposure
 * @description Exposure of exception details (like messages and stack traces) to external users
 *              may reveal internal implementation details that could assist an attacker in crafting
 *              further exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// Import the Python library for analyzing Python code
import python

// Import the custom StackTraceExposureQuery module for data flow analysis
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import the PathGraph class from the StackTraceExposureFlow namespace
import StackTraceExposureFlow::PathGraph

// Define query to identify potential exposure paths of stack trace information
from 
  StackTraceExposureFlow::PathNode sourceNode, 
  StackTraceExposureFlow::PathNode sinkNode
where 
  StackTraceExposureFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "$@ reaches this location and could be exposed to an external user.", 
  sourceNode.getNode(),
  "Stack trace information"