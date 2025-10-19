/**
 * @name Summarized callable call sites
 * @description Identifies call sites invoking summarized callables
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
import meta.MetaMetrics

// Define analysis variables: invocation node, summarized target, and call type
from DataFlow::Node invocationNode, SummarizedCallable summarizedTarget, string callType
where
  // Exclude call sites located in ignored files
  not invocationNode.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // Direct invocation scenario: matches call sites of the summarized callable
    (invocationNode = summarizedTarget.getACall() and callType = "Call")
    or
    // Callback invocation scenario: matches callback sites of the summarized callable
    (invocationNode = summarizedTarget.getACallback() and callType = "Callback")
  )
// Output invocation node with formatted call type and target information
select invocationNode, callType + " to " + summarizedTarget