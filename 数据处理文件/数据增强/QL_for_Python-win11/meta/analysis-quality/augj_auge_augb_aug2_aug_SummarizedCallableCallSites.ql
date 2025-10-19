/**
 * @name Summarized Callable Call Sites
 * @description Identifies invocation points covered by flow summaries,
 *              including both direct function calls and callback executions.
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
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callClassification
where
  // Exclude call sites located in ignored files from analysis
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  // Determine the type of invocation: either direct call or callback execution
  exists(string classification |
    // Case 1: Direct function call scenario
    (callSite = summarizedCallable.getACall() and classification = "Call")
    or
    // Case 2: Callback execution scenario
    (callSite = summarizedCallable.getACallback() and classification = "Callback")
    |
    // Assign the determined classification to the result variable
    callClassification = classification
  )
// Format result message and select call site with its classification
select callSite, callClassification + " to " + summarizedCallable