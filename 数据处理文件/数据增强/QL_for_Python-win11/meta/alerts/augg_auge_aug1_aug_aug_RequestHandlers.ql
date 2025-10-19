/**
 * @name HTTP Request Handler Identification
 * @description Detects HTTP server request handlers in Python source code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Python code data flow tracking framework
private import semmle.python.dataflow.new.DataFlow

// Essential Python language constructs and abstractions
private import semmle.python.Concepts

// Meta-analysis metric calculation utilities
private import meta.MetaMetrics

// Checks if a request handler is relevant for analysis by excluding those in ignored files
predicate isRelevantHandler(Http::Server::RequestHandler handler) {
  // Exclude handlers located in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
}

// Identifies and describes request handlers that are relevant
from Http::Server::RequestHandler handler, string handlerDesc
where
  // Apply handler relevance filter
  isRelevantHandler(handler) and
  // Generate description based on handler type
  (
    // For method-based handlers
    handler.isMethod() and
    handlerDesc = "Method " + 
                  handler.getScope().(Class).getName() + 
                  "." + 
                  handler.getName()
    or
    // For non-method handlers
    not handler.isMethod() and
    handlerDesc = handler.toString()
  )
// Output formatted handler identification
select handler, "RequestHandler: " + handlerDesc