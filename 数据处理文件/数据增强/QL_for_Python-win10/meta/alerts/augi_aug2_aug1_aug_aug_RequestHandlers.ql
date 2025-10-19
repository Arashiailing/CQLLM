/**
 * @name Request Handlers Identification
 * @description Detects and categorizes HTTP server request handlers in Python code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Python language analysis framework
private import python

// Data flow analysis capabilities for Python
private import semmle.python.dataflow.new.DataFlow

// Python language constructs and abstractions
private import semmle.python.Concepts

// Meta-analysis utilities for metrics calculation
private import meta.MetaMetrics

/**
 * Determines if a handler is eligible for analysis by excluding
 * handlers located in ignored files.
 */
predicate isEligibleHandler(Http::Server::RequestHandler handler) {
  not handler.getLocation().getFile() instanceof IgnoredFile
}

/**
 * Generates descriptive text for request handlers based on their type.
 * For method-based handlers, includes class and method name.
 * For function-based handlers, uses the standard string representation.
 */
predicate describeHandler(Http::Server::RequestHandler handler, string description) {
  (handler.isMethod() and 
   description = "Method " + 
                 handler.getScope().(Class).getName() + 
                 "." + 
                 handler.getName())
  or
  (not handler.isMethod() and 
   description = handler.toString())
}

// Primary query logic for handler identification
from Http::Server::RequestHandler handler, string description
where
  // Filter for eligible handlers
  isEligibleHandler(handler) and
  // Generate handler description
  describeHandler(handler, description)
// Output handler identification with formatted description
select handler, "RequestHandler: " + description