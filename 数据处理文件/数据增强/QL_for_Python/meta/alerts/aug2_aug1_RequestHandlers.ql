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

// Define the main query to identify HTTP server request handlers
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Exclude handlers located in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile and
  (
    // Case 1: Handler is a method within a class
    exists(Class enclosingClass |
      requestHandler.isMethod() and
      enclosingClass = requestHandler.getScope() and
      handlerDescription = "Method " + enclosingClass.getName() + "." + requestHandler.getName()
    )
    or
    // Case 2: Handler is not a method (e.g., function)
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
// Select the handler with a descriptive title prefix
select requestHandler, "RequestHandler: " + handlerDescription