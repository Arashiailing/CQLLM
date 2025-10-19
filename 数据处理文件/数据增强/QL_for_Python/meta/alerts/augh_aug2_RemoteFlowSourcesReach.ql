/**
 * @name Remote Input Taint Propagation
 * @description Detects code elements that can be influenced by remote user inputs through taint analysis.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-input-taint-propagation
 * @tags meta
 * @precision very-low
 */

// Core Python language imports
private import python
// Data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta metrics utilities
private import meta.MetaMetrics
// Internal print node handling
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration for tracking taint propagation from remote inputs
module RemoteInputTaintConfig implements DataFlow::ConfigSig {
  // Define valid source nodes for taint analysis
  predicate isSource(DataFlow::Node inputSource) {
    // Sources must originate from remote flow sources and not be in ignored files
    inputSource instanceof RemoteFlowSource and
    not inputSource.getLocation().getFile() instanceof IgnoredFile
  }

  // Define valid sink nodes for taint analysis
  predicate isSink(DataFlow::Node targetSink) {
    // Sinks must not be located in ignored files
    not targetSink.getLocation().getFile() instanceof IgnoredFile
    // Optimization note: Sink reduction was evaluated (limiting to localFlowStep/readStep/storeStep)
    // but resulted in only ~40% reduction with increased maintenance overhead
  }
}

// Global taint tracking module based on remote input configuration
module RemoteInputTaintTracking = TaintTracking::Global<RemoteInputTaintConfig>;

// Main query to identify all nodes contaminated by remote input sources
from DataFlow::Node contaminatedNode
where RemoteInputTaintTracking::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)