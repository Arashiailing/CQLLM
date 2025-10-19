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

// Configuration module for tracking remote taint propagation
module RemoteTaintPropagationConfig implements DataFlow::ConfigSig {
  /**
   * Source definition: Remote inputs excluding ignored files
   */
  predicate isSource(DataFlow::Node src) {
    src instanceof RemoteFlowSource and
    not src.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Sink definition: All nodes outside ignored files
   * Note: Sink scope could be reduced to nodes involved in
   * localFlowStep/readStep/storeStep operations. However,
   * this approach is fragile and requires constant maintenance
   * as data flow library evolves. Testing shows only ~40%
   * reduction in scope, insufficient for meta queries.
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the defined configuration
module RemoteTaintTracking = TaintTracking::Global<RemoteTaintPropagationConfig>;

// Query: Identify all nodes tainted by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteTaintTracking::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)