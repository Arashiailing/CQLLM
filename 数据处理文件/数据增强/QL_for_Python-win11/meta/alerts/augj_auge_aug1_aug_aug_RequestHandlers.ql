/**
 * @name HTTP Request Handler Identification
 * @description Detects HTTP server request handling components in Python codebases
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Python data flow analysis framework
private import semmle.python.dataflow.new.DataFlow

// Fundamental Python programming constructs
private import semmle.python.Concepts

// Meta-analysis utilities for metric calculations
private import meta.MetaMetrics

// Predicate to validate if a request handler should be included in analysis
predicate isValidRequestHandler(Http::Server::RequestHandler requestHandler) {
  // Exclude handlers located in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
}

// Main analysis logic to identify and describe request handlers
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Apply validation filter to request handlers
  isValidRequestHandler(requestHandler) and
  // Generate appropriate description based on handler type
  (
    // Case 1: Handler is implemented as a class method
    requestHandler.isMethod() and
    handlerDescription = "Method " + 
                         requestHandler.getScope().(Class).getName() + 
                         "." + 
                         requestHandler.getName()
    or
    // Case 2: Handler is not a method (function or other type)
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
// Output formatted identification of request handlers
select requestHandler, "RequestHandler: " + handlerDescription