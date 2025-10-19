/**
 * @name HTTP Server Request Handlers
 * @description Detects HTTP server request handler implementations in Python codebases
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis framework
private import python

// Import data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow

// Import fundamental Python programming constructs
private import semmle.python.Concepts

// Import metrics calculation utilities
private import meta.MetaMetrics

// Define query to identify HTTP request handlers
from Http::Server::RequestHandler requestHandler, string description
where
  // Filter out handlers in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
  and (
    // Case 1: Handler is a class method
    exists(Class handlerClass |
      requestHandler.isMethod() and
      handlerClass = requestHandler.getScope() and
      description = "Method " + handlerClass.getName() + "." + requestHandler.getName()
    )
    or
    // Case 2: Handler is a standalone function
    not requestHandler.isMethod() and
    description = requestHandler.toString()
  )
// Output handler with formatted description
select requestHandler, "RequestHandler: " + description