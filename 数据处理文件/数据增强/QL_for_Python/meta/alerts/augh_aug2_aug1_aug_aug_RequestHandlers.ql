/**
 * @name Request Handlers Identification
 * @description Identifies and categorizes HTTP server request handlers in Python source code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Data flow tracking framework for Python
private import semmle.python.dataflow.new.DataFlow

// Core Python language constructs and concepts
private import semmle.python.Concepts

// Metrics calculation utilities for meta-analysis
private import meta.MetaMetrics

/**
 * Predicate to determine if a request handler should be considered for analysis.
 * Excludes handlers located in files marked as ignored.
 */
predicate isValidRequestHandler(Http::Server::RequestHandler handler) {
  // Filter out handlers in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
}

/**
 * Generates a descriptive string for a request handler based on its type.
 * For method-based handlers, includes class name and method name.
 * For function-based handlers, uses the default string representation.
 */
predicate getHandlerDescription(Http::Server::RequestHandler handler, string description) {
  (
    handler.isMethod() and
    description = "Method " + 
                 handler.getScope().(Class).getName() + 
                 "." + 
                 handler.getName()
  )
  or
  (
    not handler.isMethod() and
    description = handler.toString()
  )
}

// Main query to identify and describe request handlers
from Http::Server::RequestHandler handler, string description
where
  // Ensure handler is valid for analysis and generate appropriate description
  isValidRequestHandler(handler) and
  getHandlerDescription(handler, description)
// Output formatted handler identification
select handler, "RequestHandler: " + description