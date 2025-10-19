/**
 * @name Summarized callable call sites
 * @description Identifies call sites where summarized callables are invoked
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import essential Python language modules
import python
// Import data flow tracking capabilities
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta analysis utilities
import meta.MetaMetrics

// Identify call sites invoking summarized callables
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callType
where
  // Exclude calls in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // Handle direct function invocations
    (callSite = summarizedCallable.getACall() and callType = "Call")
    or
    // Handle callback function invocations
    (callSite = summarizedCallable.getACallback() and callType = "Callback")
  )
// Generate results with call site and invocation type details
select callSite, callType + " to " + summarizedCallable