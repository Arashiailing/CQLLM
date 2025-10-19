/**
 * @name Remote Flow Source Reachability Analysis
 * @description Identifies all code nodes reachable via taint tracking from remote user input sources.
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

// Configuration for remote flow taint analysis
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Identifies valid remote flow sources.
   * Requires the node to be a remote source and not in an ignored file.
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Identifies valid sink nodes.
   * Excludes nodes in ignored files.
   * Note: Broad sink definition maximizes coverage. Narrowing scope (e.g., to localFlowStep,
   * readStep, or storeStep nodes) reduces coverage by ~40% with added maintenance cost.
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking using the defined configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Query: Find all nodes tainted by remote flow sources
from DataFlow::Node taintedNode
where RemoteFlowTaintAnalysis::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)