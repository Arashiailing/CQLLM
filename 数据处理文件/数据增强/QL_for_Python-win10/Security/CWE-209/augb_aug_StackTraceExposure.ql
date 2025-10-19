/**
 * @name Information exposure through an exception
 * @description Identifies potential exposure of exception details (messages and stack traces) 
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

// Import Python analysis framework
import python

// Import stack trace exposure data flow analysis module
import semmle.python.security.dataflow.StackTraceExposureQuery

// Import path graph representation for flow visualization
import StackTraceExposureFlow::PathGraph

// Identify data flow paths where stack trace details may be exposed
from StackTraceExposureFlow::PathNode sourceNode, StackTraceExposureFlow::PathNode sinkNode
where StackTraceExposureFlow::flowPath(sourceNode, sinkNode) // Verify existence of data flow path
select sinkNode.getNode(), sourceNode, sinkNode, // Report sink location with path context
  "$@ propagates to this location and could be exposed to an external user.", sourceNode.getNode(), // Describe information flow
  "Stack trace details" // Specify type of sensitive information