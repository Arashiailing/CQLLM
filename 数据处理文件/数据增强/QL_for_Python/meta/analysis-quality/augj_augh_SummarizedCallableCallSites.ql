/**
 * @name Summarized callable call sites
 * @description Identifies call sites associated with summarized callables
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import core Python language support
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import summarized callable definitions
import semmle.python.dataflow.new.FlowSummary
// Import metadata metrics utilities
import meta.MetaMetrics

// Identify relevant call sites and their invocation types
from DataFlow::Node invocationPoint, SummarizedCallable targetFunction, string callCategory
where
  // Exclude calls located in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
  and
  // Match either direct function calls or callback invocations
  (
    // Case 1: Direct function/method calls
    (invocationPoint = targetFunction.getACall() and callCategory = "Call")
    or
    // Case 2: Callback invocations
    (invocationPoint = targetFunction.getACallback() and callCategory = "Callback")
  )
// Output invocation point with call type and target function
select invocationPoint, callCategory + " to " + targetFunction