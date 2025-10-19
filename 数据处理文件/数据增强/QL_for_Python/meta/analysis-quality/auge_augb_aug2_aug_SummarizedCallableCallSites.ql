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

// Define analysis elements: invocation point, summarized callable, and call classification
from DataFlow::Node invocationPoint, SummarizedCallable summarizedFunction, string invocationType
where
  // Filter out invocation points located in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
  and
  // Classify invocation as either direct call or callback
  (
    // Direct function call scenario
    (invocationPoint = summarizedFunction.getACall() and invocationType = "Call")
    or
    // Callback execution scenario
    (invocationPoint = summarizedFunction.getACallback() and invocationType = "Callback")
  )
// Format result message and select invocation point with classification
select invocationPoint, invocationType + " to " + summarizedFunction