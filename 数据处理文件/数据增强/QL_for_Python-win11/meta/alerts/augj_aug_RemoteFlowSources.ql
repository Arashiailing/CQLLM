/**
 * @name Remote flow sources
 * @description Identifies sources of remote user input that could introduce security risks
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis support
private import python

// Data flow tracking framework for taint analysis
private import semmle.python.dataflow.new.DataFlow

// Remote input source identification capabilities
private import semmle.python.dataflow.new.RemoteFlowSources

// Metadata collection and reporting utilities
private import meta.MetaMetrics

// Identify remote input sources while excluding ignored files
from RemoteFlowSource remoteSource
where 
  // Exclude sources located in ignored files
  not remoteSource.getLocation().getFile() instanceof IgnoredFile

// Report identified sources with their type classification
select remoteSource, "RemoteFlowSource: " + remoteSource.getSourceType()