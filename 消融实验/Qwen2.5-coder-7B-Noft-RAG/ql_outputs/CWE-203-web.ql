/**
* @name CWE-203: Observable Discrepancy
*
@description Exposing sensitive information in stack traces
*
@id py/web
*/
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
from PathNode source, PathNode sink
    where StackTraceExposureFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information exposed in stack trace", source.getNode()