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

// Find locations where summarized callables are invoked
from DataFlow::Node invocationPoint, SummarizedCallable summarizedFunc, string invocationType
where
  // Filter out invocations in excluded files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // Process direct function calls
    (invocationPoint = summarizedFunc.getACall() and invocationType = "Call")
    or
    // Process callback function invocations
    (invocationPoint = summarizedFunc.getACallback() and invocationType = "Callback")
  )
// Generate result with invocation point and type information
select invocationPoint, invocationType + " to " + summarizedFunc