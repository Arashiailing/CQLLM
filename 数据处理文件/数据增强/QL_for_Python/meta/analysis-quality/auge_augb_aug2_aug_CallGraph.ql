/**
 * @name Call graph
 * @description Identifies and represents edges in the call graph, connecting invocation points to their callable targets.
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

// Select all valid call graph edges between call locations and their target functions
from DataFlowCall callLocation, DataFlowCallable targetFunction
where
  // Ensure both the call location and target function are not in ignored files
  not (
    callLocation.getLocation().getFile() instanceof IgnoredFile or
    targetFunction.getScope().getLocation().getFile() instanceof IgnoredFile
  )
  // Verify that the target function is a valid callable for this specific call location
  and targetFunction = viableCallable(callLocation)
select callLocation, "Call to $@", targetFunction.getScope(), targetFunction.toString()