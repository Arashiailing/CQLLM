/**
 * @name Remote Flow Source Reachability Analysis
 * @description Identifies code nodes reachable via taint propagation from remote user inputs.
 *              This analysis helps understand the potential impact surface of external data sources.
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
 * Taint tracking configuration for remote flow source analysis.
 * Defines sources and sinks while excluding ignored files.
 */
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  /**
   * Defines sink nodes for taint analysis. Valid sinks are those not located
   * in ignored files. This broad definition ensures maximum analysis coverage.
   */
  predicate isSink(DataFlow::Node snkNode) {
    not snkNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Identifies valid remote flow sources. Sources must be remote user inputs
   * and not located in ignored files to be considered for analysis.
   */
  predicate isSource(DataFlow::Node srcNode) {
    srcNode instanceof RemoteFlowSource and
    not srcNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking analysis using the defined configuration
module RemoteFlowTaintAnalysis = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Query execution: Find nodes tainted by remote flow sources
from DataFlow::Node taintedNd
where RemoteFlowTaintAnalysis::flow(_, taintedNd)
select taintedNd, prettyNode(taintedNd)