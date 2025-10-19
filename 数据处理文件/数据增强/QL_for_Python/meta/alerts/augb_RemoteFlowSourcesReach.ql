/**
 * @name Remote flow sources reach
 * @description Identifies nodes reachable via taint tracking from remote user input sources.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// Core Python language imports
private import python
// Data flow analysis framework imports
private import semmle.python.dataflow.new.DataFlow
// Taint propagation tracking imports
private import semmle.python.dataflow.new.TaintTracking
// Remote input source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta-analysis metrics utilities
private import meta.MetaMetrics
// Debugging print node utilities
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration module for remote flow source reachability analysis
module RemoteFlowSourceReachAnalysisConfig implements DataFlow::ConfigSig {
  // Predicate identifying valid source nodes
  predicate isSource(DataFlow::Node entryPoint) {
    // Entry point must be a remote flow source outside ignored files
    entryPoint instanceof RemoteFlowSource and
    not entryPoint.getLocation().getFile() instanceof IgnoredFile
  }

  // Predicate identifying valid sink nodes
  predicate isSink(DataFlow::Node exitPoint) {
    // Exit points must reside outside ignored files
    not exitPoint.getLocation().getFile() instanceof IgnoredFile
    // Note: Sink reduction was considered but deemed impractical due to:
    // 1) Maintenance overhead when updating data flow libraries
    // 2) Limited effectiveness (only ~40% reduction in test projects)
    // 3) Insufficient benefit for meta-analysis queries
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowSourceReachTaintFlow = TaintTracking::Global<RemoteFlowSourceReachAnalysisConfig>;

// Query selecting all nodes reachable from remote flow sources
from DataFlow::Node taintedNode
where RemoteFlowSourceReachTaintFlow::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)