/**
 * @name Remote Flow Source Reachability Analysis
 * @description Detects all code elements that can be reached through taint propagation from remote input sources.
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

// Taint tracking configuration for remote flow reachability
module RemoteFlowReachabilityConfig implements DataFlow::ConfigSig {
  /**
   * Defines acceptable sink nodes by excluding ignored files.
   * Note: Broad sink definition maximizes coverage. Narrowing scope (e.g., to localFlowStep,
   * readStep, or storeStep nodes) reduces coverage by ~40% with added maintenance cost.
   */
  predicate isSink(DataFlow::Node targetNode) {
    not targetNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Defines valid remote flow origin points.
   * Requires the node to be a remote source and not located in ignored files.
   */
  predicate isSource(DataFlow::Node originNode) {
    originNode instanceof RemoteFlowSource and
    not originNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint propagation engine using configured reachability rules
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowReachabilityConfig>;

// Query: Identify all nodes contaminated by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteFlowTaintAnalysis::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)