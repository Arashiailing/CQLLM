/**
 * @name Remote Flow Source Reachability Analysis
 * @description Detects all code nodes reachable through taint propagation from remote user inputs.
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

// Taint tracking configuration for remote flow source analysis
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Identifies valid remote input sources
   * Excludes sources in ignored files
   */
  predicate isSource(DataFlow::Node srcNode) {
    srcNode instanceof RemoteFlowSource and
    not srcNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Defines sink nodes for taint analysis
   * Uses broad sink definition for maximum coverage
   * Excludes sinks in ignored files
   */
  predicate isSink(DataFlow::Node destNode) {
    not destNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint propagation analysis using defined configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Query execution: Find nodes tainted by remote sources
from DataFlow::Node contaminatedNode
where RemoteFlowTaintAnalysis::flow(_, contaminatedNode)
select contaminatedNode, prettyNode(contaminatedNode)