/**
 * @name Clear-text logging of sensitive information
 * @description Detects unencrypted logging of sensitive data that could expose 
 *              confidential information to unauthorized access
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

// Core analysis framework imports
import python
// Data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow
// Path visualization utilities
import CleartextLoggingFlow::PathGraph
// Specialized cleartext logging detection
import semmle.python.security.dataflow.CleartextLoggingQuery

// Define key data flow components
from
  CleartextLoggingFlow::PathNode sensitiveDataOrigin, 
  CleartextLoggingFlow::PathNode loggingDestination, 
  string sensitiveDataType
where
  // Verify complete data flow path exists
  CleartextLoggingFlow::flowPath(sensitiveDataOrigin, loggingDestination)
  and
  // Extract classification from sensitive data source
  exists(Source src |
    src = sensitiveDataOrigin.getNode() and
    sensitiveDataType = src.getClassification()
  )
select 
  // Output results with sink location and flow details
  loggingDestination.getNode(), 
  sensitiveDataOrigin, 
  loggingDestination, 
  "This expression logs $@ as clear text.", 
  sensitiveDataOrigin.getNode(),
  "sensitive data (" + sensitiveDataType + ")"