/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import Python library for parsing and analyzing Python code
private import python

// Import data flow analysis library for tracking data flow in the program
private import semmle.python.dataflow.new.DataFlow

// Import Python concepts library containing common Python programming concepts
private import semmle.python.Concepts

// Import MetaMetrics library for calculating and reporting metadata metrics
private import meta.MetaMetrics

// Select HTTP request handlers and their descriptive titles
from Http::Server::RequestHandler httpRequestHandler, string handlerTitle
where
  // Exclude handlers located in ignored files
  not httpRequestHandler.getLocation().getFile() instanceof IgnoredFile and
  // Generate appropriate title based on handler type
  (
    // Case 1: Handler is a method within a class
    httpRequestHandler.isMethod() and
    handlerTitle = "Method " + httpRequestHandler.getScope().(Class).getName() + "." + httpRequestHandler.getName()
  )
  or
  (
    // Case 2: Handler is not a method (e.g., function)
    not httpRequestHandler.isMethod() and
    handlerTitle = httpRequestHandler.toString()
  )
// Output the handler with a prefixed title for clear identification
select httpRequestHandler, "RequestHandler: " + handlerTitle