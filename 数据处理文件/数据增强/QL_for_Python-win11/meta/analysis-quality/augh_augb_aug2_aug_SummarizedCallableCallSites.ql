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
from DataFlow::Node invocationPoint, SummarizedCallable summarizedFunc, string invocationCategory
where
  // Classify invocation type and establish relationship to summarized function
  (
    // Direct function call scenario
    invocationPoint = summarizedFunc.getACall() and invocationCategory = "Call"
    or
    // Callback execution scenario
    invocationPoint = summarizedFunc.getACallback() and invocationCategory = "Callback"
  )
  and
  // Filter out invocations in excluded files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
// Generate result with formatted classification message
select invocationPoint, invocationCategory + " to " + summarizedFunc