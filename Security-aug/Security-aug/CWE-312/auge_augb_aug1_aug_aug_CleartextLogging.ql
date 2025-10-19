/**
 * @name Unencrypted logging of confidential data
 * @description Identifies instances where sensitive information is logged without encryption,
 *              creating potential exposure of confidential data through insecure logging practices.
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

// Define variables for tracking data flow path components
from
  CleartextLoggingFlow::PathNode sensitiveDataOrigin, 
  CleartextLoggingFlow::PathNode loggingSink, 
  string dataClassification
where
  // Establish data flow path between source and sink
  CleartextLoggingFlow::flowPath(sensitiveDataOrigin, loggingSink)
  and
  // Extract data classification from source node
  exists(Source sourceNode |
    sourceNode = sensitiveDataOrigin.getNode() and
    dataClassification = sourceNode.getClassification()
  )
select 
  // Generate results with sink location, source node, sink node, message, and data classification
  loggingSink.getNode(), 
  sensitiveDataOrigin, 
  loggingSink, 
  "This expression logs $@ as clear text.", 
  sensitiveDataOrigin.getNode(),
  "sensitive data (" + dataClassification + ")"