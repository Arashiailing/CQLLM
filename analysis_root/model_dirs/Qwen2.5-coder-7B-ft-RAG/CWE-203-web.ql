/**
 * @name CWE-203: Observable Discrepancy
 * @description nan
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/web
 */

import python
import semmle.python.Concepts
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Observable discrepancy depends on a $@", source.getNode(), "user-provided value"