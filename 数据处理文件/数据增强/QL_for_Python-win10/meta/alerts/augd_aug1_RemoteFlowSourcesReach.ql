/**
 * @name Remote flow sources reach
 * @description Identifies nodes reachable via taint tracking from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Core Python analysis libraries
private import python
// Data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta metrics utilities
private import meta.MetaMetrics
// Internal print node utilities
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration defining taint tracking sources and sinks
module RemoteFlowConfig implements DataFlow::ConfigSig {
  /**
   * Identifies valid remote flow sources.
   * Sources must be remote flow inputs and not reside in ignored files.
   */
  predicate isSource(DataFlow::Node remoteSource) {
    remoteSource instanceof RemoteFlowSource and
    not remoteSource.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Identifies valid sink nodes.
   * Sinks must not be located in ignored files.
   * Note: Broad sink definition maximizes coverage. Restricting to specific
   * step types (localFlowStep, readStep, storeStep) reduces coverage by ~40%
   * with increased maintenance complexity.
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking using the configuration
module RemoteFlowTaintTracking = TaintTracking::Global<RemoteFlowConfig>;

// Main query: Identify nodes tainted by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteFlowTaintTracking::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)