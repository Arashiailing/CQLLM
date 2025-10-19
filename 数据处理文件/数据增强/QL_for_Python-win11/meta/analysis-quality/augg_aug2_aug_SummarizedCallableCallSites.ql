/**
 * @name Summarized Callable Call Sites
 * @description Identifies call sites covered by flow summaries, including direct calls and callback invocations.
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

from DataFlow::Node callSiteNode, SummarizedCallable targetCallable, string callCategory
where
  (
    // Check for direct function calls
    callSiteNode = targetCallable.getACall() and callCategory = "Call"
    or
    // Check for callback invocations
    callSiteNode = targetCallable.getACallback() and callCategory = "Callback"
  )
  and
  // Exclude call sites in ignored files
  not callSiteNode.getLocation().getFile() instanceof IgnoredFile
select callSiteNode, callCategory + " to " + targetCallable