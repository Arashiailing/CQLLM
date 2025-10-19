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

// Configuration module for tracking taint propagation from remote inputs
module RemoteInputTaintPropagationConfig implements DataFlow::ConfigSig {
  /**
   * Defines the sources for taint tracking: remote user inputs,
   * excluding those located in ignored files.
   */
  predicate isSource(DataFlow::Node inputSource) {
    inputSource instanceof RemoteFlowSource and
    not inputSource.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Defines the sinks for taint tracking: any node not located in ignored files.
   * Note: While the sink scope could be limited to nodes involved in specific
   * data flow operations (localFlowStep/readStep/storeStep), this approach
   * would be fragile and require frequent updates as the data flow library evolves.
   * Empirical testing indicates this would only reduce the scope by approximately 40%,
   * which is insufficient for the purposes of this meta query.
   */
  predicate isSink(DataFlow::Node targetNode) {
    not targetNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the remote input propagation configuration
module RemoteInputTaintPropagation = TaintTracking::Global<RemoteInputTaintPropagationConfig>;

// Main query: Identify all nodes that have been tainted by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteInputTaintPropagation::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)