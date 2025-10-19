/**
 * @name Summarized callable call sites
 * @description Identifies call sites where summarized callables are invoked
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import Python language support
import python
// Import data flow analysis modules
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta metrics utilities
import meta.MetaMetrics

// Define invocation sites and summarized callables
from DataFlow::Node invocationSite, SummarizedCallable summarizedFunc, string invocationType
where
  // Exclude call sites in ignored files
  not invocationSite.getLocation().getFile() instanceof IgnoredFile
  and (
    // Handle direct callable invocations
    invocationSite = summarizedFunc.getACall() 
    and invocationType = "Call"
    or
    // Handle callback invocations
    invocationSite = summarizedFunc.getACallback() 
    and invocationType = "Callback"
  )
// Format output with call site and invocation type
select invocationSite, invocationType + " to " + summarizedFunc