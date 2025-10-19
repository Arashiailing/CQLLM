/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis capabilities
private import python

// Import data flow tracking functionality
private import semmle.python.dataflow.new.DataFlow

// Import Python language concept definitions
private import semmle.python.Concepts

// Import meta metrics calculation utilities
private import meta.MetaMetrics

// Define predicate to check if a request handler should be included in results
predicate isIncludedHandler(Http::Server::RequestHandler requestHandler) {
  // Only include handlers that are not in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
}

// Define predicate to generate description for method-based handlers
predicate isMethodHandler(Http::Server::RequestHandler requestHandler, string handlerDescription) {
  requestHandler.isMethod() and
  handlerDescription = "Method " + 
                      requestHandler.getScope().(Class).getName() + 
                      "." + 
                      requestHandler.getName()
}

// Define predicate to generate description for non-method handlers
predicate isNonMethodHandler(Http::Server::RequestHandler requestHandler, string handlerDescription) {
  not requestHandler.isMethod() and
  handlerDescription = requestHandler.toString()
}

// Select HTTP server request handlers and their descriptive titles
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Ensure handler is included in analysis
  isIncludedHandler(requestHandler) and
  // Generate appropriate description based on handler type
  (
    isMethodHandler(requestHandler, handlerDescription)
    or
    isNonMethodHandler(requestHandler, handlerDescription)
  )
// Output handler with prefixed description
select requestHandler, "RequestHandler: " + handlerDescription