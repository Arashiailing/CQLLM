/**
 * @name Summarized callable call sites
 * @description Identifies call sites where summarized callables are invoked
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import Python language support
import python
// Import data flow analysis modules
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta metrics utilities
import meta.MetaMetrics

// Identify call sites with summarized callables
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callKind
where
  // Exclude call sites in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile and
  (
    // Handle direct callable invocations
    (callSite = summarizedCallable.getACall() and callKind = "Call")
    or
    // Handle callback invocations
    (callSite = summarizedCallable.getACallback() and callKind = "Callback")
  )
// Format output with call site and invocation type
select callSite, callKind + " to " + summarizedCallable