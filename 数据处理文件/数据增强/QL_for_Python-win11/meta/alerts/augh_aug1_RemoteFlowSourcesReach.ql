/**
 * @name Remote flow sources reach
 * @description Identifies nodes reachable via taint tracking from remote user input sources.
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
module RemoteFlowSourceReachConfiguration implements DataFlow::ConfigSig {
  /**
   * Determines if a node is a valid remote flow source.
   * Valid sources must be remote flow sources not located in ignored files.
   */
  predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource and
    not source.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Determines if a node is a valid sink.
   * Valid sinks must not be located in ignored files.
   * Note: Uses broad sink definition for maximum coverage.
   * Restricting sink scope (e.g., to localFlowStep/readStep/storeStep)
   * reduces coverage by ~40% while increasing maintenance complexity.
   */
  predicate isSink(DataFlow::Node sink) {
    not sink.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowSourceReachTaintTracking = TaintTracking::Global<RemoteFlowSourceReachConfiguration>;

// Main query: Find all nodes tainted by remote flow sources
from DataFlow::Node tainted
where RemoteFlowSourceReachTaintTracking::flow(_, tainted)
select tainted, prettyNode(tainted)