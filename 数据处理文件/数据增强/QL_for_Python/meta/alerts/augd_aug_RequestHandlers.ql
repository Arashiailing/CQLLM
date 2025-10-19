/**
 * @name Request Handlers
 * @description Identifies HTTP server request handlers in the codebase
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import necessary modules for Python code analysis
private import python

// Import data flow analysis capabilities for tracking program data flow
private import semmle.python.dataflow.new.DataFlow

// Import common Python programming concepts and abstractions
private import semmle.python.Concepts

// Import MetaMetrics for metadata calculation and reporting
private import meta.MetaMetrics

// Select HTTP request handlers and their descriptive labels
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Exclude handlers located in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile and
  // Generate descriptive label based on handler type
  (
    // Method handlers: include class and method names
    requestHandler.isMethod() and
    handlerDescription = "Method " + requestHandler.getScope().(Class).getName() + "." + requestHandler.getName()
    or
    // Non-method handlers: use string representation
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
// Output handler with prefixed descriptive label
select requestHandler, "RequestHandler: " + handlerDescription