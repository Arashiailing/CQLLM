/**
 * @name Python Call Graph Analysis
 * @description Identifies and represents edges in the call graph between invocation points and their potential target functions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// Import Python language support
import python
// Import internal data flow analysis utilities
import semmle.python.dataflow.new.internal.DataFlowPrivate
// Import meta metrics utilities
import meta.MetaMetrics

// Define call graph edges between invocation points and their viable callable targets
from DataFlowCall callSite, DataFlowCallable targetFunction
where
  // Ensure the target function is a viable candidate for the call site
  targetFunction = viableCallable(callSite)
  // Exclude call sites located in ignored files
  and not callSite.getLocation().getFile() instanceof IgnoredFile
  // Exclude target functions whose scope is in ignored files
  and not targetFunction.getScope().getLocation().getFile() instanceof IgnoredFile
select callSite, "Call to $@", targetFunction.getScope(), targetFunction.toString()