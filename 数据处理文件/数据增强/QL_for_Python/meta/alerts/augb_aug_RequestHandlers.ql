/**
 * @name Request Handlers
 * @description Detects HTTP server request handlers across the codebase
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core modules for Python code analysis
private import python

// Import data flow tracking capabilities for program analysis
private import semmle.python.dataflow.new.DataFlow

// Import fundamental Python programming constructs
private import semmle.python.Concepts

// Import MetaMetrics for metadata computation
private import meta.MetaMetrics

// Identify request handlers and generate descriptive labels
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Filter out handlers in excluded files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
  and (
    // Handle method-based request processors
    requestHandler.isMethod() and
    handlerDescription = "Method " + requestHandler.getScope().(Class).getName() + "." + requestHandler.getName()
    or
    // Handle non-method request processors
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
// Output handler with prefixed descriptive label
select requestHandler, "RequestHandler: " + handlerDescription