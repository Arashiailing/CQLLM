/**
 * @name Summarized callable call sites
 * @description Identifies locations where summarized callables are invoked
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import Python language support
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// Import meta metrics utilities
import meta.MetaMetrics

// Define variables for call location, summarized function, and invocation type
from DataFlow::Node callLocation, SummarizedCallable summarizedFunc, string invocationType
where
  // Check if the location represents a direct call to the summarized function
  (callLocation = summarizedFunc.getACall() and invocationType = "Call")
  or
  // Check if the location represents a callback to the summarized function
  (callLocation = summarizedFunc.getACallback() and invocationType = "Callback") and
  // Filter out call sites located in ignored files
  not callLocation.getLocation().getFile() instanceof IgnoredFile
// Output the call location with a descriptive message
select callLocation, invocationType + " to " + summarizedFunc