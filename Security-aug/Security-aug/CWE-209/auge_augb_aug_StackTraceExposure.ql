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

// Python analysis framework import
import python

// Stack trace exposure data flow analysis module import
import semmle.python.security.dataflow.StackTraceExposureQuery

// Path graph representation import for flow visualization
import StackTraceExposureFlow::PathGraph

// Identification of data flow paths where stack trace details may be exposed
from StackTraceExposureFlow::PathNode originNode, StackTraceExposureFlow::PathNode targetNode
where StackTraceExposureFlow::flowPath(originNode, targetNode) // Verify existence of data flow path
select targetNode.getNode(), originNode, targetNode, // Report sink location with path context
  "$@ propagates to this location and could be exposed to " + // Describe information flow
  "an external user.", originNode.getNode(),
  "Stack trace details" // Specify type of sensitive information