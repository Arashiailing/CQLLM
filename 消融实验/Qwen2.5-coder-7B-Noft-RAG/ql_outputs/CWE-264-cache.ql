/**
* @name Stack Trace Exposure Query
* @kind path-problem
* @problem.severity error
* @security-severity 5.4
* @precision high
*
@id py/stack-trace-exposure
*
@tags security * external/cwe/cwe-209 * external/cwe/cwe-497
*/
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph
from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
    where StackTraceExposureFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Information exposure through an exception", source.getNode(), "user-provided value"