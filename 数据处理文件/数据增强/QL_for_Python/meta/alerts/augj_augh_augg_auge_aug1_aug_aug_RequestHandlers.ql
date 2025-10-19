/**
 * @name HTTP Request Handler Identification
 * @description Identifies HTTP server request handlers in Python source code by analyzing
 *              the code structure and providing detailed descriptions of each handler.
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

// Identify relevant request handlers by filtering out ignored files
from Http::Server::RequestHandler httpRequestHandler, string handlerInfo
where
  // Exclude handlers located in ignored files
  not httpRequestHandler.getLocation().getFile() instanceof IgnoredFile and
  // Generate handler description based on type
  (
    // Method-based handler description
    httpRequestHandler.isMethod() and
    handlerInfo = "Method " + 
                  httpRequestHandler.getScope().(Class).getName() + 
                  "." + 
                  httpRequestHandler.getName()
    or
    // Non-method handler description
    not httpRequestHandler.isMethod() and
    handlerInfo = httpRequestHandler.toString()
  )
// Output formatted handler identification
select httpRequestHandler, "RequestHandler: " + handlerInfo