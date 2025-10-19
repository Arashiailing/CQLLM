/**
 * @name Remote flow sources reach
 * @description Identifies nodes reachable via taint tracking from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Import Python language support
private import python
// Import data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Import remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Import meta metrics utilities
private import meta.MetaMetrics
// Import internal print node support
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration for tracking reachability from remote flow sources
module RemoteFlowReachConfig implements DataFlow::ConfigSig {
  /**
   * Sink definition: All nodes not in ignored files.
   * Note: Sink scope could be reduced by limiting to nodes involved in
   * localFlowStep/readStep/storeStep operations. However, this approach
   * is fragile and would require constant maintenance as the data flow
   * library evolves. Testing shows only ~40% reduction in scope,
   * which isn't sufficient justification for meta queries.
   */
  predicate isSink(DataFlow::Node targetNode) {
    not targetNode.getLocation().getFile() instanceof IgnoredFile
  }

  // Source definition: Remote inputs not in ignored files
  predicate isSource(DataFlow::Node originNode) {
    originNode instanceof RemoteFlowSource and
    not originNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowReachFlow = TaintTracking::Global<RemoteFlowReachConfig>;

// Query: Find all nodes tainted by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteFlowReachFlow::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)