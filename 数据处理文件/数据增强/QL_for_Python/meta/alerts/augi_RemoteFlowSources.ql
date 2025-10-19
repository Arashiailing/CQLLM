/**
 * @name Remote flow sources
 * @description Identifies sources of remote user input in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// Essential libraries for Python code analysis
private import python

// Data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow

// Specialized module for remote input source detection
private import semmle.python.dataflow.new.RemoteFlowSources

// Metadata collection and reporting utilities
private import meta.MetaMetrics

// Identify all remote input sources
from RemoteFlowSource remoteInputSource

// Exclude sources from ignored files
where not remoteInputSource.getLocation().getFile() instanceof IgnoredFile

// Report findings with source type description
select remoteInputSource, "RemoteFlowSource: " + remoteInputSource.getSourceType()