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

// Select call graph edges between call sites and their viable callable targets
from DataFlowCall callerNode, DataFlowCallable calleeFunc
where
  // Verify the target function is a viable callable for the call site
  calleeFunc = viableCallable(callerNode)
  // Exclude call sites located in ignored files
  and not callerNode.getLocation().getFile() instanceof IgnoredFile
  // Exclude target functions whose scope is in ignored files
  and not calleeFunc.getScope().getLocation().getFile() instanceof IgnoredFile
select callerNode, "Call to $@", calleeFunc.getScope(), calleeFunc.toString()