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

// Configuration module for tracking remote flow source reachability
module RemoteFlowReachConfig implements DataFlow::ConfigSig {
  // Define source nodes: remote inputs not in ignored files
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  // Define sink nodes: all nodes not in ignored files
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
    // Note: Sink scope could be reduced by limiting to nodes involved in
    // localFlowStep/readStep/storeStep operations. However, this approach
    // is fragile and would require constant maintenance as the data flow
    // library evolves. Testing shows only ~40% reduction in scope,
    // which isn't sufficient justification for meta queries.
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowReachFlow = TaintTracking::Global<RemoteFlowReachConfig>;

// Query: Find all nodes tainted by remote flow sources
from DataFlow::Node taintedNode
where RemoteFlowReachFlow::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)