/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in the codebase
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import necessary modules for Python code analysis
private import python

// Import data flow analysis capabilities for tracking program data flow
private import semmle.python.dataflow.new.DataFlow

// Import common Python programming concepts and abstractions
private import semmle.python.Concepts

// Import MetaMetrics for metadata calculation and reporting
private import meta.MetaMetrics

// Select HTTP request handlers and their descriptions
from Http::Server::RequestHandler handler, string description
where
  // Exclude handlers located in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile and
  // Determine the appropriate description based on handler type
  (
    // For method handlers, construct a descriptive string with class and method names
    handler.isMethod() and
    description = "Method " + handler.getScope().(Class).getName() + "." + handler.getName()
  )
  or
  (
    // For non-method handlers, use the string representation
    not handler.isMethod() and
    description = handler.toString()
  )
// Output the handler with a prefixed description
select handler, "RequestHandler: " + description