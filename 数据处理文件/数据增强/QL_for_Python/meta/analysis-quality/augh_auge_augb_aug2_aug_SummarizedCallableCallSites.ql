/**
 * @name Summarized Callable Call Sites
 * @description Identifies call sites covered by flow summaries,
 *              including direct function calls and callback executions.
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

// Define analysis elements: call site, summarized callable, and call classification
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callCategory
where
  // Exclude call sites located in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  // Classify call as direct function call or callback execution
  (
    // Direct function call scenario
    callSite = summarizedCallable.getACall() and callCategory = "Call"
    or
    // Callback execution scenario
    callSite = summarizedCallable.getACallback() and callCategory = "Callback"
  )
// Format result message with call site and classification details
select callSite, callCategory + " to " + summarizedCallable