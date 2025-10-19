/**
 * @name Summarized callable call sites
 * @description Identifies locations where summarized callables are invoked or referenced as callbacks.
 *              This analysis helps track function usage patterns across codebase by capturing both
 *              direct function calls and callback assignments.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
import meta.MetaMetrics

// Define analysis variables: call site location, summarized callable, and invocation type
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string invocationType

// Check if the call site is valid (not in ignored files)
where 
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // Case 1: Direct function invocation
    (
      callSite = summarizedCallable.getACall() 
      and invocationType = "Call"
    )
    or
    // Case 2: Callback reference (e.g., function passed as argument)
    (
      callSite = summarizedCallable.getACallback() 
      and invocationType = "Callback"
    )
  )

// Output the call site with detailed invocation information
select callSite, invocationType + " to " + summarizedCallable