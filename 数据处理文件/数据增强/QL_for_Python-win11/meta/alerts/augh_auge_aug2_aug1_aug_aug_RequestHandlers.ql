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
 * Filters request handlers by excluding those located in ignored files.
 * @param requestHandler The request handler to evaluate
 */
predicate isHandlerEligible(Http::Server::RequestHandler requestHandler) {
  // Exclude handlers present in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
}

/**
 * Generates descriptive information for a request handler based on its type.
 * @param requestHandler The request handler to describe
 * @param handlerDescription The generated description string
 */
predicate generateHandlerDescription(Http::Server::RequestHandler requestHandler, string handlerDescription) {
  // Case 1: Method-based handlers
  exists(string className, string methodName |
    requestHandler.isMethod() and
    className = requestHandler.getScope().(Class).getName() and
    methodName = requestHandler.getName() and
    handlerDescription = "Method " + className + "." + methodName
  )
  or
  // Case 2: Function-based handlers
  (
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
}

// Main query for identifying and describing request handlers
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Apply eligibility filter and generate description
  isHandlerEligible(requestHandler) and
  generateHandlerDescription(requestHandler, handlerDescription)
// Output formatted handler identification
select requestHandler, "RequestHandler: " + handlerDescription