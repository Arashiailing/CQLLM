/**
 * @name HTTP Request Handler Identification
 * @description Identifies HTTP server request handlers within Python source code for security analysis
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Python code data flow tracking framework
private import semmle.python.dataflow.new.DataFlow

// Essential Python language constructs and abstractions
private import semmle.python.Concepts

// Meta-analysis metric calculation utilities
private import meta.MetaMetrics

// Determines if a request handler should be analyzed by filtering out handlers in ignored files
predicate isRelevantHandler(Http::Server::RequestHandler httpHandler) {
  // Exclude handlers located in files marked for ignoring
  not httpHandler.getLocation().getFile() instanceof IgnoredFile
}

// Extracts descriptive information about request handlers
string getHandlerDescription(Http::Server::RequestHandler httpHandler) {
  // For method-based handlers, include class and method name
  exists(Class cls |
    httpHandler.isMethod() and
    cls = httpHandler.getScope() and
    result = "Method " + cls.getName() + "." + httpHandler.getName()
  )
  or
  // For non-method handlers, use standard string representation
  not httpHandler.isMethod() and
  result = httpHandler.toString()
}

// Identifies and reports relevant HTTP request handlers
from Http::Server::RequestHandler httpHandler, string handlerDescription
where
  // Filter for relevant handlers
  isRelevantHandler(httpHandler) and
  // Generate appropriate description
  handlerDescription = getHandlerDescription(httpHandler)
// Output formatted handler identification
select httpHandler, "RequestHandler: " + handlerDescription