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

from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string invocationType
where
  // Exclude invocations in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // Handle direct function invocations
    (callSite = summarizedCallable.getACall() and invocationType = "Call")
    or
    // Handle asynchronous callback scenarios
    (callSite = summarizedCallable.getACallback() and invocationType = "Callback")
  )
select callSite, invocationType + " to " + summarizedCallable