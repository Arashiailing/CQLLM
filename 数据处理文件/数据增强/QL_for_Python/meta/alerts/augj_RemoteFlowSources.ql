/**
 * @name Remote flow sources
 * @description Identifies sources of remote user input in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// Core Python analysis libraries
private import python

// Data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow

// Remote input source identification
private import semmle.python.dataflow.new.RemoteFlowSources

// Metadata collection and reporting
private import meta.MetaMetrics

// Identify all remote flow sources
from RemoteFlowSource remoteSource

// Exclude sources from ignored files
where not remoteSource.getLocation().getFile() instanceof IgnoredFile

// Report remote source with type description
select remoteSource, "RemoteFlowSource: " + remoteSource.getSourceType()