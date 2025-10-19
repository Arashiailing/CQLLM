/**
 * @name Remote Flow Sources
 * @description Identifies sources of remote user input that may introduce security risks
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// Core Python analysis libraries
private import python

// Data flow tracking framework
private import semmle.python.dataflow.new.DataFlow

// Remote input source identification
private import semmle.python.dataflow.new.RemoteFlowSources

// Metadata collection and reporting
private import meta.MetaMetrics

// Identify remote input sources excluding ignored files
from RemoteFlowSource remoteSource
where 
  // Exclude sources located in ignored files
  not remoteSource.getLocation().getFile() instanceof IgnoredFile
select 
  remoteSource, 
  "RemoteFlowSource: " + remoteSource.getSourceType()