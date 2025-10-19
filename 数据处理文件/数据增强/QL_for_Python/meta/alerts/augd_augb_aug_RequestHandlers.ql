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

// Identify HTTP server request handlers and generate descriptive labels
from Http::Server::RequestHandler handler, string description
where
  // Exclude handlers located in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
  and
  // Generate appropriate description based on handler type
  (
    // Case 1: Handler is a method within a class
    handler.isMethod() and
    description = "Method " + handler.getScope().(Class).getName() + "." + handler.getName()
  )
  or
  (
    // Case 2: Handler is not a method (e.g., function)
    not handler.isMethod() and
    description = handler.toString()
  )
// Output each handler with its prefixed descriptive label
select handler, "RequestHandler: " + description