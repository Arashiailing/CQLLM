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
from DataFlowCall invocationPoint, DataFlowCallable calleeFunction
where
  // Ensure the callee function is a viable target for the invocation point
  calleeFunction = viableCallable(invocationPoint)
  // Exclude invocation points located in ignored files
  and not invocationPoint.getLocation().getFile() instanceof IgnoredFile
  // Exclude callee functions whose scope is in ignored files
  and not calleeFunction.getScope().getLocation().getFile() instanceof IgnoredFile
select invocationPoint, "Call to $@", calleeFunction.getScope(), calleeFunction.toString()