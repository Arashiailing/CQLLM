/**
 * @name Python Call Graph Analysis
 * @description Identifies and represents edges in the call graph between function invocation points and their viable callable targets.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// Import Python language analysis framework
import python
// Import internal data flow analysis utilities for call graph construction
import semmle.python.dataflow.new.internal.DataFlowPrivate
// Import meta metrics utilities for code analysis
import meta.MetaMetrics

// Define call graph edges between function call sites and their potential target functions
from DataFlowCall callerLocation, DataFlowCallable targetFunction
where
  // Filter out call sites and target functions located in ignored files
  not callerLocation.getLocation().getFile() instanceof IgnoredFile
  and not targetFunction.getScope().getLocation().getFile() instanceof IgnoredFile
  // Ensure the target function is a viable callable for the specific call site
  and targetFunction = viableCallable(callerLocation)
select callerLocation, "Call to $@", targetFunction.getScope(), targetFunction.toString()