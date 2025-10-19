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

// Taint tracking configuration for remote flow analysis
module RemoteFlowConfig implements DataFlow::ConfigSig {
  /**
   * Defines valid remote flow sources.
   * Sources must be remote inputs and not reside in excluded files.
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Defines valid sink nodes.
   * Sinks must not be located in excluded files.
   * Note: Broad sink definition maximizes coverage. Restricting to specific
   * step types (localFlowStep, readStep, storeStep) reduces coverage by ~40%
   * with increased maintenance complexity.
   */
  predicate isSink(DataFlow::Node destinationNode) {
    not destinationNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking implementation
module RemoteFlowTaintTracking = TaintTracking::Global<RemoteFlowConfig>;

// Main query: Identify nodes tainted by remote flow sources
from DataFlow::Node taintedNode
where RemoteFlowTaintTracking::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)