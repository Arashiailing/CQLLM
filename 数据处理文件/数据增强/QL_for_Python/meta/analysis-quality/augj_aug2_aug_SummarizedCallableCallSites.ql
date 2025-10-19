/**
 * @name Summarized Callable Call Sites
 * @description Identifies call sites covered by flow summaries, 
 *              including both direct function calls and callback invocations.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import Python language core library
import python
// Import data flow analysis modules
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta metrics analysis module
import meta.MetaMetrics

// Define analysis variables: call site node, target summarized callable, and call type
from DataFlow::Node callSite, SummarizedCallable targetCallable, string callType
where
  // Check if the call site is a direct invocation of the summarized target
  (callSite = targetCallable.getACall() and callType = "Call")
  or
  // Check if the call site is a callback invocation of the summarized target
  (callSite = targetCallable.getACallback() and callType = "Callback")
  and
  // Ensure the call site is not located in an ignored file
  not callSite.getLocation().getFile() instanceof IgnoredFile
// Format result message and select the call site with its description
select callSite, callType + " to " + targetCallable