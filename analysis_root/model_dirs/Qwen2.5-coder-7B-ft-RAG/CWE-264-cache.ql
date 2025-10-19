/**
 * @name CWE-264: Stack Trace Exposure
 * @description Exposing stack traces to external users may reveal internal system details
 *              which could aid in crafting subsequent attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This stack trace may be exposed to an external user via a $@", source.getNode(),
  "user-provided exception message"