/**
 * @name Summarized callable invocation sites
 * @description Identifies code locations where summarized callables are invoked
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

// Identify invocation sites and their corresponding summarized callables
from DataFlow::Node invocationSite, SummarizedCallable summarizedFunc, string invocationType
where
  // Filter out invocation sites in ignored files
  not invocationSite.getLocation().getFile() instanceof IgnoredFile
  and (
    // Direct invocation case
    (invocationSite = summarizedFunc.getACall() and invocationType = "Call")
    or
    // Callback invocation case
    (invocationSite = summarizedFunc.getACallback() and invocationType = "Callback")
  )
// Format output with invocation details
select invocationSite, invocationType + " to " + summarizedFunc