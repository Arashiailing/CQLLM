/**
 * @name Information exposure through an exception
 * @description Leaking exception details (messages/stack traces) to external users 
 *              can reveal implementation details useful for developing exploits.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497 */

// Core Python analysis libraries
import python

// Stack trace exposure data flow analysis module
import semmle.python.security.dataflow.StackTraceExposureQuery

// Path graph for tracking stack trace information flows
import StackTraceExposureFlow::PathGraph

// Identify paths where stack trace information flows to external users
from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode destination
where StackTraceExposureFlow::flowPath(source, destination)
select destination.getNode(), source, destination,
  "$@ flows to this location and may be exposed to an external user.", source.getNode(),
  "Stack trace information"