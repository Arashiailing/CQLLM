/**
 * @name Call graph
 * @description Represents an edge in the call graph between caller and callee.
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

// Select call graph edges between call sites and their viable target functions
from DataFlowCall callSite, DataFlowCallable targetFunction
where
  // Exclude call sites located in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  // Exclude target functions whose scope is in ignored files
  and not targetFunction.getScope().getLocation().getFile() instanceof IgnoredFile
  // Verify the target function is a viable callable for the call site
  and targetFunction = viableCallable(callSite)
select callSite, "Call to $@", targetFunction.getScope(), targetFunction.toString()