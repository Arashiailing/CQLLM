/**
 * @name Unencrypted logging of confidential data
 * @description Identifies instances where sensitive information is logged without encryption,
 *              potentially exposing confidential data to unauthorized access.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/clear-text-logging-sensitive-data
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-359
 *       external/cwe/cwe-532
 */

// Import Python language support
import python
// Import data flow tracking functionality
private import semmle.python.dataflow.new.DataFlow
// Import path visualization components
import CleartextLoggingFlow::PathGraph
// Import specialized cleartext logging analysis
import semmle.python.security.dataflow.CleartextLoggingQuery

// Declare variables for tracking data flow path components
from
  CleartextLoggingFlow::PathNode sensitiveDataSrc, 
  CleartextLoggingFlow::PathNode loggingSink, 
  string dataClassification
where
  // Establish data flow path between source and sink
  CleartextLoggingFlow::flowPath(sensitiveDataSrc, loggingSink)
  and
  // Verify source node represents sensitive data
  exists(Source src |
    src = sensitiveDataSrc.getNode() and
    // Extract data classification from source
    dataClassification = src.getClassification()
  )
select 
  // Generate results with sink location, source node, sink node, message, and data classification
  loggingSink.getNode(), 
  sensitiveDataSrc, 
  loggingSink, 
  "This expression logs $@ as clear text.", 
  sensitiveDataSrc.getNode(),
  "sensitive data (" + dataClassification + ")"