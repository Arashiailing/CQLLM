/**
 * @name Remote Flow Source Reachability Analysis
 * @description Identifies all code nodes that can be reached via taint tracking from remote user input sources.
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

// Taint tracking configuration module for remote flow sources
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Identifies valid remote flow sources
   * Excludes sources located in ignored files
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Defines valid sink nodes for taint analysis
   * Uses broad definition to maximize coverage
   * Excludes sinks located in ignored files
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking analysis using the configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Query execution: Identify nodes tainted by remote sources
from DataFlow::Node taintedNode
where RemoteFlowTaintAnalysis::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)