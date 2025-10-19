/**
 * @name Summarized callable call sites
 * @description Identifies call sites where a summarized callable is invoked
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

// Identify call sites and their corresponding summarized callables
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callKind
where
  // Exclude call sites located in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile and
  (
    // Case 1: Direct call to summarized callable
    (callSite = summarizedCallable.getACall() and callKind = "Call")
    or
    // Case 2: Callback invocation of summarized callable
    (callSite = summarizedCallable.getACallback() and callKind = "Callback")
  )
// Format output with call site and invocation type details
select callSite, callKind + " to " + summarizedCallable