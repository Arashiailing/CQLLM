/**
 * @name HTTP Request Handlers Detection
 * @description Identifies and reports HTTP server request handlers in Python applications
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Import core Python language analysis capabilities
private import python

// Import data flow analysis framework for tracking code execution
private import semmle.python.dataflow.new.DataFlow

// Import fundamental Python programming constructs and patterns
private import semmle.python.Concepts

// Import metrics calculation and reporting functionality
private import meta.MetaMetrics

// Define query to detect HTTP server request handlers
from Http::Server::RequestHandler handler, string description
where
  // Filter out handlers in excluded files
  not handler.getLocation().getFile() instanceof IgnoredFile and
  (
    // First scenario: Handler is defined as a class method
    exists(Class containerClass |
      handler.isMethod() and
      containerClass = handler.getScope() and
      description = "Method " + containerClass.getName() + "." + handler.getName()
    )
    or
    // Second scenario: Handler is a standalone function
    not handler.isMethod() and
    description = handler.toString()
  )
// Output results with consistent formatting
select handler, "RequestHandler: " + description