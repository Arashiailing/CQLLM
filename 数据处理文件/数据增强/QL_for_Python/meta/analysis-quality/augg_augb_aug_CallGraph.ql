/**
 * @name Call graph
 * @description Represents call graph edges by connecting function invocation sites with their corresponding callable targets.
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

// Define variables representing invocation sites and their target callables
from DataFlowCall invocationSite, DataFlowCallable targetCallable
where
  // Establish valid callable relationship between invocation and target
  targetCallable = viableCallable(invocationSite)
  // Filter out invocations located in ignored files
  and not invocationSite.getLocation().getFile() instanceof IgnoredFile
  // Filter out targets defined in ignored files
  and not targetCallable.getScope().getLocation().getFile() instanceof IgnoredFile
select invocationSite, "Call to $@", targetCallable.getScope(), targetCallable.toString()