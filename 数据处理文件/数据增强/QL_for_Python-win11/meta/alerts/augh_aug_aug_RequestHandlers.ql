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
predicate isIncludedHandler(Http::Server::RequestHandler handler) {
  // Only include handlers that are not in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
}

// Define predicate to generate description for handlers based on their type
predicate getHandlerDescription(Http::Server::RequestHandler handler, string descriptor) {
  // For method-based handlers, create a description with class and method name
  handler.isMethod() and
  descriptor = "Method " + 
              handler.getScope().(Class).getName() + 
              "." + 
              handler.getName()
  or
  // For non-method handlers, use the default string representation
  not handler.isMethod() and
  descriptor = handler.toString()
}

// Select HTTP server request handlers and their descriptive titles
from Http::Server::RequestHandler handler, string descriptor
where
  // Ensure handler is included in analysis and get its description
  isIncludedHandler(handler) and
  getHandlerDescription(handler, descriptor)
// Output handler with prefixed description
select handler, "RequestHandler: " + descriptor