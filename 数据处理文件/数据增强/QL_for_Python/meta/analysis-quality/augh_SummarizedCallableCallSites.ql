/**
 * @name Summarized callable call sites
 * @description Identifies call sites associated with summarized callables
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// Import core Python language support
import python
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import summarized callable definitions
import semmle.python.dataflow.new.FlowSummary
// Import metadata metrics utilities
import meta.MetaMetrics

// Identify call sites with summarized callables
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string invocationKind
where
  // Exclude locations in ignored files
  not callSite.getLocation().getFile() instanceof IgnoredFile
  and (
    // Match direct function/method calls
    (callSite = summarizedCallable.getACall() and invocationKind = "Call")
    or
    // Match callback invocations
    (callSite = summarizedCallable.getACallback() and invocationKind = "Callback")
  )
// Output call site with invocation type and target
select callSite, invocationKind + " to " + summarizedCallable