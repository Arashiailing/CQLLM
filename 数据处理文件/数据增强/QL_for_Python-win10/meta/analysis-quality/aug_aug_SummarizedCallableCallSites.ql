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

from DataFlow::Node invocationPoint, SummarizedCallable summaryFunc, string callType
where
  // Handle direct function invocations
  (invocationPoint = summaryFunc.getACall() and callType = "Call")
  or
  // Handle asynchronous callback scenarios
  (invocationPoint = summaryFunc.getACallback() and callType = "Callback")
  and
  // Filter out invocations in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
select invocationPoint, callType + " to " + summaryFunc