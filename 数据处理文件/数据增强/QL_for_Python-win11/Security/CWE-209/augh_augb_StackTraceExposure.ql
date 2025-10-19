/**
 * @name Information exposure through an exception
 * @description Revealing exception details (messages/stack traces) to external users 
 *              can disclose implementation details that aid attackers in crafting exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497 */

// Import Python code analysis framework
import python

// Import custom stack trace exposure module for data flow analysis
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import path graph class from StackTraceExposureFlow namespace
import StackTraceExposureFlow::PathGraph

// Identify paths where stack trace information flows to external users
from StackTraceExposureFlow::PathNode sourceNode, StackTraceExposureFlow::PathNode sinkNode
where StackTraceExposureFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode,
  "$@ propagates to this location and risks exposure to external users.", sourceNode.getNode(),
  "Stack trace details"