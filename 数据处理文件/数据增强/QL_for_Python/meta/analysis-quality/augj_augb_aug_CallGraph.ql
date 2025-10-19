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

// Define variables representing call sites and their target callables
from DataFlowCall callSite, DataFlowCallable targetCallable
where
  // Establish valid call relationship between site and target
  targetCallable = viableCallable(callSite)
  // Filter out call sites located in ignored files
  and not callSite.getLocation().getFile() instanceof IgnoredFile
  // Filter out target callables defined in ignored files
  and not targetCallable.getScope().getLocation().getFile() instanceof IgnoredFile
select callSite, "Call to $@", targetCallable.getScope(), targetCallable.toString()