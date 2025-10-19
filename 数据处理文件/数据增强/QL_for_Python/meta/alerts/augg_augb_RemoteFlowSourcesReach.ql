/**
 * @name Remote flow sources reach
 * @description Identifies nodes reachable via taint tracking from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Core Python language imports
private import python
// Data flow analysis framework imports
private import semmle.python.dataflow.new.DataFlow
// Taint propagation tracking imports
private import semmle.python.dataflow.new.TaintTracking
// Remote input source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta-analysis metrics utilities
private import meta.MetaMetrics
// Debugging print node utilities
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration module for tracking reachability from remote sources
module RemoteSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Holds if `sourceNode` is a remote flow source outside ignored files.
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Holds if `sinkNode` resides outside ignored files.
   * Note: Sink reduction was avoided due to:
   * 1) Maintenance overhead when updating data flow libraries
   * 2) Limited effectiveness (~40% reduction in test projects)
   * 3) Insufficient benefit for meta-analysis queries
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the defined configuration
module RemoteSourceTaintFlow = TaintTracking::Global<RemoteSourceReachConfig>;

// Query selecting all nodes reachable from remote flow sources
from DataFlow::Node reachableNode
where RemoteSourceTaintFlow::flow(_, reachableNode)
select reachableNode, prettyNode(reachableNode)