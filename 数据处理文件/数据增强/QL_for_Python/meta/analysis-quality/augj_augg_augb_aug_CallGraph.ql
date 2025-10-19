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

// Define variables representing call sites and their target functions
from DataFlowCall callSite, DataFlowCallable calledFunction
where
  // Establish valid callable relationship between call site and target
  calledFunction = viableCallable(callSite)
  // Exclude invocations in ignored files
  and not callSite.getLocation().getFile() instanceof IgnoredFile
  // Exclude targets defined in ignored files
  and not calledFunction.getScope().getLocation().getFile() instanceof IgnoredFile
select callSite, "Call to $@", calledFunction.getScope(), calledFunction.toString()