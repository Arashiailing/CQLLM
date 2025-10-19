/**
 * @name HTTP Server Request Handlers Detection
 * @description Identifies implementations of HTTP server request handlers in Python codebases
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
from Http::Server::RequestHandler httpReqHandler, string handlerDescription
where
  // Exclude handlers located in ignored files
  not httpReqHandler.getLocation().getFile() instanceof IgnoredFile
  and (
    // Check if handler is implemented as a class method
    exists(Class enclosingClass |
      httpReqHandler.isMethod() and
      enclosingClass = httpReqHandler.getScope() and
      handlerDescription = "Method " + enclosingClass.getName() + "." + httpReqHandler.getName()
    )
    or
    // Check if handler is implemented as a standalone function
    not httpReqHandler.isMethod() and
    handlerDescription = httpReqHandler.toString()
  )
// Output handler with formatted description
select httpReqHandler, "RequestHandler: " + handlerDescription