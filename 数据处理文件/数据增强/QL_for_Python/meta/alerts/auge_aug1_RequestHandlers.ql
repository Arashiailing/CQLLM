/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import Python analysis libraries
private import python

// Import data flow analysis capabilities
private import semmle.python.dataflow.new.DataFlow

// Import common Python programming concepts
private import semmle.python.Concepts

// Import metrics calculation and reporting utilities
private import meta.MetaMetrics

// Identify HTTP server request handlers with descriptive titles
from Http::Server::RequestHandler requestHandler, string handlerDescriptor
where
  // Exclude handlers in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
  and (
    // Case 1: Method-based handler within a class
    exists(Class enclosingClass |
      requestHandler.isMethod() and
      enclosingClass = requestHandler.getScope() and
      handlerDescriptor = "Method " + enclosingClass.getName() + "." + requestHandler.getName()
    )
    or
    // Case 2: Non-method handler (e.g., standalone function)
    not requestHandler.isMethod() and
    handlerDescriptor = requestHandler.toString()
  )
// Select handler with prefixed descriptive title
select requestHandler, "RequestHandler: " + handlerDescriptor