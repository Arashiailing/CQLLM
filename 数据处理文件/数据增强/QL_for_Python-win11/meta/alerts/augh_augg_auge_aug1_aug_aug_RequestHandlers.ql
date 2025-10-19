/**
 * @name HTTP Request Handler Identification
 * @description Identifies HTTP server request handlers in Python source code
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

// Identify relevant request handlers by filtering ignored files
from Http::Server::RequestHandler requestHandler, string handlerDescription
where
  // Exclude handlers located in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile and
  // Generate handler description based on type
  (
    // Method-based handler description
    requestHandler.isMethod() and
    handlerDescription = "Method " + 
                         requestHandler.getScope().(Class).getName() + 
                         "." + 
                         requestHandler.getName()
    or
    // Non-method handler description
    not requestHandler.isMethod() and
    handlerDescription = requestHandler.toString()
  )
// Output formatted handler identification
select requestHandler, "RequestHandler: " + handlerDescription