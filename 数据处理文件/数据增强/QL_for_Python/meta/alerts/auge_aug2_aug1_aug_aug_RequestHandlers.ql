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
 * Determines if a request handler is eligible for analysis by filtering out handlers
 * located in files marked as ignored.
 */
predicate isEligibleHandler(Http::Server::RequestHandler handler) {
  // Exclude handlers present in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile
}

/**
 * Generates a descriptive string for a request handler based on its type.
 * For method-based handlers, includes class and method name.
 * For function-based handlers, uses the string representation.
 */
predicate getHandlerInfo(Http::Server::RequestHandler handler, string handlerInfo) {
  exists(string className, string methodName |
    handler.isMethod() and
    className = handler.getScope().(Class).getName() and
    methodName = handler.getName() and
    handlerInfo = "Method " + className + "." + methodName
  )
  or
  (
    not handler.isMethod() and
    handlerInfo = handler.toString()
  )
}

// Main query to identify and describe request handlers
from Http::Server::RequestHandler handler, string handlerInfo
where
  // Filter for eligible handlers and generate their descriptive information
  isEligibleHandler(handler) and
  getHandlerInfo(handler, handlerInfo)
// Output formatted handler identification
select handler, "RequestHandler: " + handlerInfo