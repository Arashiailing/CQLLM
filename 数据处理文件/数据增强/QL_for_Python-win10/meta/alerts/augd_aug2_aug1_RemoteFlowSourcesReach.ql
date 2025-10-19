/**
 * @name Remote Input Taint Propagation Analysis
 * @description Detects all code elements that can be influenced by remote user inputs through taint propagation.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-input-taint-propagation
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis libraries
private import python
// Import data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Import remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Import meta metrics utilities
private import meta.MetaMetrics
// Import internal print node utilities
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration module for remote input taint tracking
module RemoteInputTaintConfig implements DataFlow::ConfigSig {
  /**
   * Determines if a node qualifies as a remote input source.
   * Valid sources must be remote flow sources outside ignored files.
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Determines if a node qualifies as a taint sink.
   * Valid sinks must be located outside ignored files.
   * Note: Broad sink definition maximizes coverage - restricting to specific
   * flow steps reduces coverage by ~40% with increased maintenance cost.
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using remote input configuration
module RemoteInputTaintTracking = TaintTracking::Global<RemoteInputTaintConfig>;

// Main query: Identify all nodes tainted by remote inputs
from DataFlow::Node taintedNode
where RemoteInputTaintTracking::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)