/**
 * @name Remote Flow Source Reachability Analysis
 * @description Identifies code nodes reachable through taint propagation from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Core analysis framework imports
private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.TaintTracking
private import semmle.python.dataflow.new.RemoteFlowSources
private import meta.MetaMetrics
private import semmle.python.dataflow.new.internal.PrintNode

/**
 * Configuration module for taint tracking analysis focused on remote flow sources.
 * Defines sources and sinks while excluding ignored files.
 */
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Holds if `srcNode` is a valid remote flow source.
   * Excludes sources located in ignored files.
   */
  predicate isSource(DataFlow::Node srcNode) {
    srcNode instanceof RemoteFlowSource and
    not srcNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Holds if `sinkNode` is a valid sink for taint analysis.
   * Uses broad definition for maximum coverage.
   * Excludes sinks located in ignored files.
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking analysis using the defined configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

/**
 * Query execution: Identify nodes tainted by remote sources.
 * Selects all nodes reachable via taint flow from remote input sources.
 */
from DataFlow::Node taintedNode
where RemoteFlowTaintAnalysis::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)