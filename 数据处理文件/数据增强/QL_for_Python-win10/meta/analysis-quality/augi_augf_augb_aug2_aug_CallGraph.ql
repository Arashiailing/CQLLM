/**
 * @name Python Call Graph Analysis
 * @description Constructs a representation of the call graph by mapping function invocation sites to their potential callable targets.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// Import the Python language analysis framework
import python
// Import specialized utilities for internal data flow analysis used in call graph construction
import semmle.python.dataflow.new.internal.DataFlowPrivate
// Import utilities for meta metrics and code analysis
import meta.MetaMetrics

// Define the relationship between function call sites and their potential target functions
from DataFlowCall invocationPoint, DataFlowCallable callableTarget
where
  // Filter out call sites located in ignored files
  not invocationPoint.getLocation().getFile() instanceof IgnoredFile and
  // Filter out target functions located in ignored files
  not callableTarget.getScope().getLocation().getFile() instanceof IgnoredFile and
  // Ensure the target function is a viable callable for the call site
  callableTarget = viableCallable(invocationPoint)
select invocationPoint, "Call to $@", callableTarget.getScope(), callableTarget.toString()