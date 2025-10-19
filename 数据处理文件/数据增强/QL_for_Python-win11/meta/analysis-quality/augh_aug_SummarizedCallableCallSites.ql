/**
 * @name Summarized callable call sites
 * @description Identifies call sites associated with summarized callables
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

// Define analysis variables: invocation point, target callable, and call type
from DataFlow::Node invocationPoint, SummarizedCallable targetCallable, string callType
where
  // Direct invocation scenario: invocation point matches callable's call site
  (invocationPoint = targetCallable.getACall() and callType = "Call")
  or
  // Callback invocation scenario: invocation point matches callable's callback site
  (invocationPoint = targetCallable.getACallback() and callType = "Callback")
  and
  // Exclude invocation points located in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile
// Output invocation point with formatted call type and target callable information
select invocationPoint, callType + " to " + targetCallable