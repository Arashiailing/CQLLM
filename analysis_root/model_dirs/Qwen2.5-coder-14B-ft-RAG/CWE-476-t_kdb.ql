/**
* @name Stack Trace Exposure
* @kind path-problem
* @id py/stack-trace-exposure
* @precision high
* @problem.severity error
* @security-severity 5.4
* @tags security
*/

import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from
  StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink,
  Http::Client::Request request
where
  StackTraceExposureFlow::flowPath(source, sink)
  and
  request = source.getNode().(Sink).getRequest()
select sink.getNode(),
  source, sink,
  "Stack trace reaches a $@ where $@.", request, "HTTP response", request.toString()