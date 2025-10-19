/**
 * @name XML external entity expansion
 * @description Identifies when user-provided input reaches an XML parser without
 *              adequate protection against external entity expansion vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis framework import
import python

// Specialized XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Path graph utilities for data flow visualization
import XxeFlow::PathGraph

// Define source and sink nodes for tainted data flow
from 
  XxeFlow::PathNode inputOrigin,  // User-controlled input source
  XxeFlow::PathNode xmlSink       // Vulnerable XML parsing sink
// Verify data flow path exists between input and insecure processing
where 
  XxeFlow::flowPath(inputOrigin, xmlSink)
// Generate security alert with complete flow path
select 
  xmlSink.getNode(), 
  inputOrigin, 
  xmlSink,
  "XML document parsing uses a $@ without safeguards against external entity expansion.",
  inputOrigin.getNode(), 
  "user-controlled input"