/**
 * @name Information exposure through an exception
 * @description Leaking information about an exception, such as messages and stack traces, to an
 *              external user can expose implementation details that are useful to an attacker for
 *              developing a subsequent exploit.
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

from
  StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink,
  StackTraceExposureFlow::PathNode messageOrigin, StackTraceExposureFlow::PathNode stackOrigin
where
  StackTraceExposureFlow::flowPath(source, sink) and
  (
    messageOrigin = source and
    stackOrigin = sink
    or
    messageOrigin = sink and
    stackOrigin = source
  )
select
  sink.getNode(), source, sink, messageOrigin, stackOrigin,
  "This expression exposes a $@ which reaches $@.",
  messageOrigin.getNode(), "message",
  stackOrigin.getNode(), "a stack trace"