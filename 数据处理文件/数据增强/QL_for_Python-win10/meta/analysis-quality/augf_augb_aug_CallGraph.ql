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

// Define variables representing call sites and their target functions
from DataFlowCall callSite, DataFlowCallable callee
where
  // Establish valid callable relationship between call site and target
  callee = viableCallable(callSite)
  // Exclude analysis for ignored files (both call site and target function)
  and not (
    callSite.getLocation().getFile() instanceof IgnoredFile
    or
    callee.getScope().getLocation().getFile() instanceof IgnoredFile
  )
select callSite, "Call to $@", callee.getScope(), callee.toString()