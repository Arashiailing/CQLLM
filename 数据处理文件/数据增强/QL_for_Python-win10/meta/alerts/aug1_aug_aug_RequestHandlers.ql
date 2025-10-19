/**
 * @name Request Handlers Identification
 * @description Detects HTTP server request handlers in Python source code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Data flow tracking framework for Python
private import semmle.python.dataflow.new.DataFlow

// Core Python language constructs and concepts
private import semmle.python.Concepts

// Metrics calculation utilities for meta-analysis
private import meta.MetaMetrics

// Predicate to filter relevant request handlers
predicate isRelevantHandler(Http::Server::RequestHandler handler) {
  // Exclude handlers located in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
}

// Main query to identify request handlers with descriptions
from Http::Server::RequestHandler handler, string description
where
  // Apply handler relevance filter
  isRelevantHandler(handler) and
  // Generate handler description based on type
  (
    // Handle method-based request handlers
    handler.isMethod() and
    description = "Method " + 
                handler.getScope().(Class).getName() + 
                "." + 
                handler.getName()
    or
    // Handle non-method request handlers
    not handler.isMethod() and
    description = handler.toString()
  )
// Output formatted handler identification
select handler, "RequestHandler: " + description