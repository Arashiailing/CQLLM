/**
 * @name Summarized Callable Call Sites
 * @description Identifies call sites that are covered by flow summaries.
 *              This includes both direct calls and callback invocations.
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

// Define analysis variables: invocation node, target summarized callable, and invocation type
from DataFlow::Node invocationNode, SummarizedCallable summarizedTarget, string invocationType
where
  // Check if the invocation node is a direct call to the summarized target
  (invocationNode = summarizedTarget.getACall() and invocationType = "Call")
  or
  // Check if the invocation node is a callback to the summarized target
  (invocationNode = summarizedTarget.getACallback() and invocationType = "Callback")
  and
  // Ensure the invocation node is not in an ignored file
  not invocationNode.getLocation().getFile() instanceof IgnoredFile
// Format the result message and select the invocation node with the message
select invocationNode, invocationType + " to " + summarizedTarget