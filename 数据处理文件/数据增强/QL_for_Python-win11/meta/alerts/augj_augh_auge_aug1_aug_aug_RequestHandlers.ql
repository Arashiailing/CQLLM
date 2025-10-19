/**
 * @name HTTP Request Handler Identification
 * @description Identifies HTTP server request handlers in Python source code,
 *              distinguishing between method-based and standalone handlers
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
from Http::Server::RequestHandler requestHandler, string handlerDescriptor
where
  // Filter out handlers in ignored files
  not requestHandler.getLocation().getFile() instanceof IgnoredFile
  and
  // Generate appropriate handler descriptor based on handler type
  (
    // Case 1: Method-based handler (class method)
    requestHandler.isMethod() and
    handlerDescriptor = "Method " + 
                         requestHandler.getScope().(Class).getName() + 
                         "." + 
                         requestHandler.getName()
    or
    // Case 2: Standalone handler (function or other)
    not requestHandler.isMethod() and
    handlerDescriptor = requestHandler.toString()
  )
// Output formatted handler identification
select requestHandler, "RequestHandler: " + handlerDescriptor