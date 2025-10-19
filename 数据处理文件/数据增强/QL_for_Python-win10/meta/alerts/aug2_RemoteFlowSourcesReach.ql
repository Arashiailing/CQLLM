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
// Data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Taint tracking capabilities
private import semmle.python.dataflow.new.TaintTracking
// Remote flow source definitions
private import semmle.python.dataflow.new.RemoteFlowSources
// Meta metrics utilities
private import meta.MetaMetrics
// Internal print node handling
private import semmle.python.dataflow.new.internal.PrintNode

// Configuration module for tracking remote flow source propagation
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  // Predicate identifying valid source nodes
  predicate isSource(DataFlow::Node sourceNode) {
    // Source must be a remote flow source outside ignored files
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  // Predicate identifying valid sink nodes
  predicate isSink(DataFlow::Node sinkNode) {
    // Sink must not be in ignored files
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
    // Note: Sink reduction was considered (limiting to localFlowStep/readStep/storeStep)
    // but only achieved ~40% reduction with added maintenance complexity
  }
}

// Global taint tracking module using the defined configuration
module RemoteFlowSourceReachFlow = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// Query to find all nodes tainted by remote flow sources
from DataFlow::Node taintedNode
where RemoteFlowSourceReachFlow::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)