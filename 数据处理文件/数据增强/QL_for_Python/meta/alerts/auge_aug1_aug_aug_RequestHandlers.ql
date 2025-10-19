/**
 * @name HTTP Request Processor Detection
 * @description Identifies HTTP server request processors in Python source code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Fundamental Python language analysis features
private import python

// Data flow tracking system for Python code
private import semmle.python.dataflow.new.DataFlow

// Core Python language elements and abstractions
private import semmle.python.Concepts

// Utilities for calculating metrics in meta-analysis
private import meta.MetaMetrics

// Predicate to determine if a request processor is relevant for analysis
predicate isRelevantProcessor(Http::Server::RequestHandler processor) {
  // Filter out processors located in ignored files
  not processor.getLocation().getFile() instanceof IgnoredFile
}

// Main query to identify and describe request processors
from Http::Server::RequestHandler processor, string processorDescription
where
  // Apply processor relevance filter
  isRelevantProcessor(processor) and
  // Generate description based on processor type
  (
    // For method-based processors
    processor.isMethod() and
    processorDescription = "Method " + 
                          processor.getScope().(Class).getName() + 
                          "." + 
                          processor.getName()
    or
    // For non-method processors
    not processor.isMethod() and
    processorDescription = processor.toString()
  )
// Output formatted processor identification
select processor, "RequestHandler: " + processorDescription