/**
 * @name HTTP Request Handler Identification
 * @description Detects HTTP server request handlers in Python source code
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// Core Python language analysis capabilities
private import python

// Data flow analysis framework for Python
private import semmle.python.dataflow.new.DataFlow

// Fundamental Python programming constructs
private import semmle.python.Concepts

// Metric calculation utilities for meta-analysis
private import meta.MetaMetrics

// Main query to identify and describe request handlers
from Http::Server::RequestHandler handler, string handlerDescription
where
  // Exclude handlers in ignored files
  not handler.getLocation().getFile() instanceof IgnoredFile and
  // Generate handler description based on type
  (
    // Method-based handler description
    handler.isMethod() and
    handlerDescription = "Method " + 
                         handler.getScope().(Class).getName() + 
                         "." + 
                         handler.getName()
    or
    // Non-method handler description
    not handler.isMethod() and
    handlerDescription = handler.toString()
  )
// Output formatted handler identification
select handler, "RequestHandler: " + handlerDescription