/**
 * @name Call graph
 * @description Identifies and represents edges in the call graph, connecting function call sites with their corresponding callable targets.
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

// Define variables for function call sites and their target functions
from DataFlowCall functionCall, DataFlowCallable targetFunction
where
  // Ensure the target function is a viable callable for the function call
  targetFunction = viableCallable(functionCall)
  // Exclude function calls in ignored files
  and not functionCall.getLocation().getFile() instanceof IgnoredFile
  // Exclude target functions in ignored files
  and not targetFunction.getScope().getLocation().getFile() instanceof IgnoredFile
select functionCall, "Call to $@", targetFunction.getScope(), targetFunction.toString()