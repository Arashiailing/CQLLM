/**
 * @name Remote Flow Source Reachability Analysis
 * @description Detects all code locations that can be influenced by remote user inputs through taint propagation.
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

// Configuration module for tracking remote source taint propagation
module RemoteSourceTrackingConfig implements DataFlow::ConfigSig {
  /**
   * Determines valid entry points for taint analysis
   * Filters out sources that originate from ignored file locations
   */
  predicate isSource(DataFlow::Node entryPointNode) {
    entryPointNode instanceof RemoteFlowSource and
    not entryPointNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * Specifies exit points for the taint tracking analysis
   * Implements a comprehensive definition to ensure maximum detection coverage
   * Excludes exit points located in ignored files
   */
  predicate isSink(DataFlow::Node exitPointNode) {
    not exitPointNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// Global taint propagation engine using the specified configuration
module GlobalTaintTracker = TaintTracking::Global<RemoteSourceTrackingConfig>;

// Main query execution: Find all nodes affected by remote source taint
from DataFlow::Node compromisedNode
where GlobalTaintTracker::flow(_, compromisedNode)
select compromisedNode, prettyNode(compromisedNode)