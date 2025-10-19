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

// Select call graph edges between invocation points and their callable targets
from DataFlowCall invocation, DataFlowCallable callee
where
  // Ensure the callee is a viable target for this invocation
  callee = viableCallable(invocation)
  // Exclude both invocation and callee if located in ignored files
  and not (
    invocation.getLocation().getFile() instanceof IgnoredFile
    or
    callee.getScope().getLocation().getFile() instanceof IgnoredFile
  )
select invocation, "Call to $@", callee.getScope(), callee.toString()