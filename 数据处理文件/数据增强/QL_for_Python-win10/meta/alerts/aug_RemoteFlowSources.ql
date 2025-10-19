/**
 * @name Remote flow sources
 * @description Identifies sources of remote user input that could introduce security risks
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

// Identify all remote input sources excluding ignored files
from RemoteFlowSource remoteInputSource
where 
  not remoteInputSource.getLocation().getFile() instanceof IgnoredFile

// Report identified sources with their type classification
select remoteInputSource, "RemoteFlowSource: " + remoteInputSource.getSourceType()