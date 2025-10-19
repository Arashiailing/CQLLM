/**
 * @name Call graph
 * @description Identifies and represents edges in the call graph, showing the relationship
 *              between a caller (call site) and its potential callee (target function).
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/call-graph
 * @tags meta
 * @precision very-low
 */

// Import Python language support and analysis capabilities
import python
// Import internal utilities for data flow analysis
import semmle.python.dataflow.new.internal.DataFlowPrivate
// Import utilities for meta metrics and analysis
import meta.MetaMetrics

// Extract call graph edges between call sites and their viable callable targets
from DataFlowCall callSite, DataFlowCallable targetCallable
where
  // Establish the relationship: target must be a viable callable for the call site
  targetCallable = viableCallable(callSite)
  // Apply filtering: exclude elements in ignored files
  and not callSite.getLocation().getFile() instanceof IgnoredFile
  and not targetCallable.getScope().getLocation().getFile() instanceof IgnoredFile
// Output the call graph edges with appropriate message formatting
select callSite, "Call to $@", targetCallable.getScope(), targetCallable.toString()