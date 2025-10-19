/**
 * @name Exception Information Exposure
 * @description Exposing exception details (like messages and stack traces) to external users
 *              can reveal implementation details that aid attackers in crafting exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497 */

// Import Python code analysis library
import python

// Import custom stack trace exposure query module for data flow analysis
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import PathGraph class from the StackTraceExposureFlow namespace
import StackTraceExposureFlow::PathGraph

// Define query to detect stack trace information flow paths that may be exposed to external users
from StackTraceExposureFlow::PathNode sourceNode, StackTraceExposureFlow::PathNode sinkNode
where StackTraceExposureFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "$@ flows to this location and may be exposed to an external user.", 
  sourceNode.getNode(),
  "Stack trace information"