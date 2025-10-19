/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis framework
private import python

// Import data flow tracking capabilities for security analysis
private import semmle.python.dataflow.new.DataFlow

// Import fundamental Python language constructs and patterns
private import semmle.python.Concepts

// Import metrics collection and reporting functionality
private import meta.MetaMetrics

// Main query to detect HTTP server request handlers
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Exclude handlers in ignored files from analysis
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
  and
  // Determine handler type and construct appropriate description
  (
    // Handler is a method within a class context
    exists(Class enclosingClass |
      requestHandler.isMethod() and
      enclosingClass = requestHandler.getScope() and
      handlerDescription = "Method " + enclosingClass.getName() + "." + requestHandler.getName()
    )
    or
    // Handler is a standalone function
    (
      not requestHandler.isMethod() and
      handlerDescription = requestHandler.toString()
    )
  )
// Output results with standardized prefix
select requestHandler, "RequestHandler: " + handlerDescription