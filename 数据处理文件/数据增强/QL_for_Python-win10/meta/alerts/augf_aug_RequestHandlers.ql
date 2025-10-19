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

// Select HTTP request handlers and their descriptions
from Http::Server::RequestHandler endpoint, string endpointDesc
where
  // Exclude handlers located in ignored files
  not endpoint.getLocation().getFile() instanceof IgnoredFile and
  // Determine description based on handler type
  (
    // Method handler case: construct description with class and method names
    endpoint.isMethod() and
    endpointDesc = "Method " + endpoint.getScope().(Class).getName() + "." + endpoint.getName()
  )
  or
  (
    // Non-method handler case: use string representation
    not endpoint.isMethod() and
    endpointDesc = endpoint.toString()
  )
// Output the handler with prefixed description
select endpoint, "RequestHandler: " + endpointDesc