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
predicate isValidRequestHandler(Http::Server::RequestHandler requestHandler) {
  // Filter out handlers in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
}

/**
 * Predicate to generate a descriptive string for method-based request handlers.
 */
predicate isMethodBasedHandler(Http::Server::RequestHandler requestHandler, string handlerDescription) {
  requestHandler.isMethod() and
  handlerDescription = "Method " + 
                     requestHandler.getScope().(Class).getName() + 
                     "." + 
                     requestHandler.getName()
}

/**
 * Predicate to generate a descriptive string for non-method request handlers.
 */
predicate isFunctionBasedHandler(Http::Server::RequestHandler requestHandler, string handlerDescription) {
  not requestHandler.isMethod() and
  handlerDescription = requestHandler.toString()
}

// Main query to identify and describe request handlers
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Ensure handler is valid for analysis
  isValidRequestHandler(requestHandler) and
  // Generate appropriate description based on handler type
  (
    isMethodBasedHandler(requestHandler, handlerDescription)
    or
    isFunctionBasedHandler(requestHandler, handlerDescription)
  )
// Output formatted handler identification
select requestHandler, "RequestHandler: " + handlerDescription