/**
 * @name Request Handlers
 * @description Detects HTTP server request handler functions throughout the codebase
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core Python analysis framework
private import python

// Import data flow tracking functionality for Python code
private import semmle.python.dataflow.new.DataFlow

// Import fundamental Python programming constructs and patterns
private import semmle.python.Concepts

// Import metadata metrics calculation utilities
private import meta.MetaMetrics

// Identify HTTP request handlers and generate appropriate labels
from Http::Server::RequestHandler httpHandler, string handlerLabel
where
  // Filter out handlers in ignored files
  not httpHandler.getLocation().getFile() instanceof IgnoredFile
  and
  // Generate appropriate label based on handler type
  (
    // Case for method-based handlers
    httpHandler.isMethod() and
    handlerLabel = "Method " + httpHandler.getScope().(Class).getName() + "." + httpHandler.getName()
  )
  or
  (
    // Case for non-method handlers
    not httpHandler.isMethod() and
    not httpHandler.getLocation().getFile() instanceof IgnoredFile and
    handlerLabel = httpHandler.toString()
  )
// Output handler with prefixed descriptive label
select httpHandler, "RequestHandler: " + handlerLabel