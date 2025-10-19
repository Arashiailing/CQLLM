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

from DataFlow::Node callSite, SummarizedCallable summarizedFunc, string invocationType
where
  // Exclude invocations occurring in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  // Identify call sites through two invocation patterns
  (
    // Pattern 1: Direct function calls
    (callSite = summarizedFunc.getACall() and invocationType = "Call")
    or
    // Pattern 2: Asynchronous callback scenarios
    (callSite = summarizedFunc.getACallback() and invocationType = "Callback")
  )
select callSite, invocationType + " to " + summarizedFunc