/**
 * @name Clear-text logging of sensitive information
 * @description Identifies instances where sensitive data is written to logs
 *              without encryption, creating a risk of exposing confidential
 *              information to unauthorized access.
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

// Import Python analysis framework
import python
// Import data flow analysis capabilities
private import semmle.python.dataflow.new.DataFlow
// Import path graph visualization utilities
import CleartextLoggingFlow::PathGraph
// Import specialized query for cleartext logging detection
import semmle.python.security.dataflow.CleartextLoggingQuery

// Define query components for data flow analysis
from
  CleartextLoggingFlow::PathNode sensitiveDataSource,  // Origin point of sensitive data
  CleartextLoggingFlow::PathNode loggingDestination,   // Target logging location
  string dataCategory                                  // Classification of sensitive data
where
  // Establish data flow connection between source and destination
  CleartextLoggingFlow::flowPath(sensitiveDataSource, loggingDestination)
  and
  // Retrieve the classification type from the sensitive data source
  exists(Source src |
    src = sensitiveDataSource.getNode() and
    dataCategory = src.getClassification()
  )
select 
  // Report findings with destination location, flow path, and classification
  loggingDestination.getNode(), 
  sensitiveDataSource, 
  loggingDestination, 
  "This expression logs $@ as clear text.", 
  sensitiveDataSource.getNode(),
  "sensitive data (" + dataCategory + ")"