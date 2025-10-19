/**
 * @name Unencrypted logging of confidential data
 * @description Detects when sensitive information is written to logs without proper encryption,
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
  CleartextLoggingFlow::PathNode confidentialDataSource, 
  CleartextLoggingFlow::PathNode logDestination, 
  string infoCategory
where
  // Establish data flow path between source and sink
  CleartextLoggingFlow::flowPath(confidentialDataSource, logDestination)
  and
  // Extract data classification from source
  exists(Source src |
    src = confidentialDataSource.getNode() and
    infoCategory = src.getClassification()
  )
select 
  // Generate results with sink location, source node, sink node, message, and data classification
  logDestination.getNode(), 
  confidentialDataSource, 
  logDestination, 
  "This expression logs $@ as clear text.", 
  confidentialDataSource.getNode(),
  "sensitive data (" + infoCategory + ")"