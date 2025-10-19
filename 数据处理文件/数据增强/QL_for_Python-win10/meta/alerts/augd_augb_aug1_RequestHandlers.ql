/**
 * @name HTTP Server Request Handlers
 * @description Identifies HTTP server request handler implementations in Python codebases
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
from Http::Server::RequestHandler httpHandler, string handlerDescription
where
  // Exclude handlers in ignored files from analysis
  not httpHandler.getLocation().getFile() instanceof IgnoredFile
  and (
    // Check if handler is a class method
    httpHandler.isMethod() and
    exists(Class containerClass |
      containerClass = httpHandler.getScope() and
      handlerDescription = "Method " + containerClass.getName() + "." + httpHandler.getName()
    )
    or
    // Check if handler is a standalone function
    not httpHandler.isMethod() and
    handlerDescription = httpHandler.toString()
  )
// Output handler with formatted description
select httpHandler, "RequestHandler: " + handlerDescription