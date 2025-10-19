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
from Http::Server::RequestHandler handler, string handlerTitle
where
  // Exclude handlers located in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile and
  (
    // Case 1: Handler is a method within a class
    exists(Class cls |
      handler.isMethod() and
      cls = handler.getScope() and
      handlerTitle = "Method " + cls.getName() + "." + handler.getName()
    )
    or
    // Case 2: Handler is not a method (e.g., function)
    not handler.isMethod() and
    handlerTitle = handler.toString()
  )
// Select the handler with a descriptive title prefix
select handler, "RequestHandler: " + handlerTitle