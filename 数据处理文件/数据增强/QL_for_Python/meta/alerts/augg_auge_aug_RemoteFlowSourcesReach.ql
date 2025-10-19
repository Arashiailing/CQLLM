/**
 * @name Remote taint propagation reachability
 * @description Tracks data flow propagation from remote input sources to all reachable nodes.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-taint-reachability
 * @tags meta
 * @precision very-low
 */

// Core Python language support
private import python
// Data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Taint tracking engine
private import semmle.python.dataflow.new.TaintTracking
// Remote input source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta metrics utilities
private import meta.MetaMetrics
// Internal node printing support
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration defining taint propagation rules
module RemoteTaintConfig implements DataFlow::ConfigSig {
  /**
   * Sink definition: All non-ignored nodes.
   * Note: Narrowing sink scope to nodes involved in localFlowStep/readStep/storeStep
   * operations was considered. However, this approach is fragile due to evolving
   * data flow library internals and only reduces scope by ~40%, which is insufficient
   * for meta-level queries to justify maintenance overhead.
   */
  predicate isSink(DataFlow::Node targetNode) {
    not targetNode.getLocation().getFile() instanceof IgnoredFile
  }

  // Source definition: Remote inputs from non-ignored files
  predicate isSource(DataFlow::Node originNode) {
    originNode instanceof RemoteFlowSource and
    not originNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint propagation analysis with defined configuration
module RemoteTaintFlow = TaintTracking::Global<RemoteTaintConfig>;

// Find all nodes tainted by remote input sources
from DataFlow::Node taintedNode
where RemoteTaintFlow::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)