/**
* @name CWE-476: Stack Trace Exposure
*
@description Exposing stack trace information in exceptions can reveal sensitive internal details.
* @kind path-problem
* @problem.severity error
* @security-severity 5.4
* @precision high
*
@id py/stack-trace-exposure
*
@tags security
*/
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph
from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
    where StackTraceExposureFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Potential stack trace exposure through exception."