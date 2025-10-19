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

// Define call sites and summarized callables with their invocation types
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callType
where
  // Ensure the call site is not in an ignored file
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and (
    // Case 1: Direct function/method call
    exists(SummarizedCallable func |
      func = summarizedCallable and
      callSite = func.getACall() and
      callType = "Call"
    )
    or
    // Case 2: Callback invocation
    exists(SummarizedCallable callback |
      callback = summarizedCallable and
      callSite = callback.getACallback() and
      callType = "Callback"
    )
  )
// Output the call site along with the invocation type and target callable
select callSite, callType + " to " + summarizedCallable