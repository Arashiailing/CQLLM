/**
 * @name Call graph
 * @description Identifies edges in the call graph, representing function/method invocations.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// Import standard Python language analysis library
import python
// Import internal data flow analysis utilities for call graph construction
import semmle.python.dataflow.new.internal.DataFlowPrivate
// Import meta metrics for additional analysis capabilities
import meta.MetaMetrics

// Define the source of our analysis: function/method invocations and their callable targets
from DataFlowCall invocation, DataFlowCallable callableTarget
where
  // Ensure the target is a viable callable for the given invocation
  callableTarget = viableCallable(invocation)
  and
  // Exclude invocations located in ignored files
  not invocation.getLocation().getFile() instanceof IgnoredFile
  and
  // Exclude callable targets whose scope is in ignored files
  not callableTarget.getScope().getLocation().getFile() instanceof IgnoredFile
select invocation, "Call to $@", callableTarget.getScope(), callableTarget.toString()