/**
 * @name Remote flow sources
 * @description Identifies external input sources that could introduce untrusted data
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// Core Python analysis framework for AST processing
private import python

// Data flow tracking engine for taint analysis
private import semmle.python.dataflow.new.DataFlow

// Remote input source classification module
private import semmle.python.dataflow.new.RemoteFlowSources

// Metadata reporting utilities
private import meta.MetaMetrics

// Identify all remote input sources while excluding ignored files
from RemoteFlowSource remoteSource
where 
  // Filter out sources located in ignored files
  not remoteSource.getLocation().getFile() instanceof IgnoredFile

// Generate alerts with source type classification
select remoteSource, "RemoteFlowSource: " + remoteSource.getSourceType()