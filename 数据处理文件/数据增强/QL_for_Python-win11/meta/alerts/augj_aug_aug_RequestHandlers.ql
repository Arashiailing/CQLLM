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

// Define predicate to check if a handler should be included in results
// Filters out handlers located in ignored files
predicate shouldIncludeHandler(Http::Server::RequestHandler handler) {
  not handler.getLocation().getFile() instanceof IgnoredFile
}

// Define predicate to generate handler description based on its type
// For method-based handlers, format as "Class.method"
// For other handlers, use the default string representation
predicate getHandlerDescription(Http::Server::RequestHandler handler, string description) {
  exists(string className, string methodName |
    handler.isMethod() and
    className = handler.getScope().(Class).getName() and
    methodName = handler.getName() and
    description = "Method " + className + "." + methodName
  )
  or
  (
    not handler.isMethod() and
    description = handler.toString()
  )
}

// Select HTTP server request handlers and their descriptive titles
from Http::Server::RequestHandler handler, string description
where
  // Filter to include only relevant handlers
  shouldIncludeHandler(handler) and
  // Generate appropriate description based on handler type
  getHandlerDescription(handler, description)
// Output handler with prefixed description
select handler, "RequestHandler: " + description