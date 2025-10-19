/**
 * @name Remote Flow Source Reachability Analysis
 * @description Identifies all code nodes that can be reached via taint tracking from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis libraries
private import python
// Import data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Import remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Import meta metrics utilities
private import meta.MetaMetrics
// Import internal print node utilities
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration module defining sources and sinks for remote flow analysis
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Determines if a node is a valid remote flow source.
   * A valid source must be a remote flow source and not located in an ignored file.
   */
  predicate isSource(DataFlow::Node inputSource) {
    inputSource instanceof RemoteFlowSource and
    not inputSource.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Determines if a node is a valid sink.
   * A valid sink must not be located in an ignored file.
   * Note: This intentionally uses a broad sink definition to maximize coverage.
   * Attempts to reduce sink scope (e.g., by restricting to localFlowStep,
   * readStep, or storeStep nodes) were found to reduce coverage by only ~40%
   * while adding maintenance complexity.
   */
  predicate isSink(DataFlow::Node outputSink) {
    not outputSink.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Main query: Find all nodes tainted by remote flow sources
from DataFlow::Node contaminatedNode
where RemoteFlowTaintAnalysis::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)