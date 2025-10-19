/**
 * @name Summarized callable call sites
 * @description Identifies call sites targeting summarized callables
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
import meta.MetaMetrics

from DataFlow::Node invocationPoint, SummarizedCallable abstractCallable, string callCategory
where
  // Filter out invocations in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
  and
  // Identify either direct function calls or asynchronous callback invocations
  (
    // Direct function calls
    invocationPoint = abstractCallable.getACall() and callCategory = "Call"
    or
    // Asynchronous callback invocations
    invocationPoint = abstractCallable.getACallback() and callCategory = "Callback"
  )
select invocationPoint, callCategory + " to " + abstractCallable