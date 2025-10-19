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

// Select call graph edges between invocation points and their viable callable targets
from DataFlowCall invocationSite, DataFlowCallable calleeFunction
where
  // Exclude call sites located in ignored files
  not invocationSite.getLocation().getFile() instanceof IgnoredFile
  // Exclude target functions whose scope is in ignored files
  and not calleeFunction.getScope().getLocation().getFile() instanceof IgnoredFile
  // Verify the target function is a viable callable for the invocation point
  and calleeFunction = viableCallable(invocationSite)
select invocationSite, "Call to $@", calleeFunction.getScope(), calleeFunction.toString()