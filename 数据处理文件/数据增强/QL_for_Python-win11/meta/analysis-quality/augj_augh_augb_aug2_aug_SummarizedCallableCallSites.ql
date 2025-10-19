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

// Import core Python language support
import python
// Import modern data flow analysis framework
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta-analysis utilities
import meta.MetaMetrics

// Define analysis elements: invocation location, summarized function, and invocation category
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string callType
where
  // Classify invocation type and establish relationship to summarized function
  (
    // Direct function call scenario
    callSite = summarizedCallable.getACall() and callType = "Call"
    or
    // Callback execution scenario
    callSite = summarizedCallable.getACallback() and callType = "Callback"
  )
  and
  // Filter out invocations in excluded files
  not callSite.getLocation().getFile() instanceof IgnoredFile
// Generate result with formatted classification message
select callSite, callType + " to " + summarizedCallable