/**
 * @name Clear-text logging of sensitive information
 * @description Detects sensitive data being logged without encryption,
 *              potentially exposing confidential information to unauthorized access.
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

// Import Python analysis libraries
import python
// Import data flow analysis framework
private import semmle.python.dataflow.new.DataFlow
// Import path graph generation utilities
import CleartextLoggingFlow::PathGraph
// Import cleartext logging detection query
import semmle.python.security.dataflow.CleartextLoggingQuery

// Define query components: data source, logging sink, and sensitivity classification
from
  CleartextLoggingFlow::PathNode dataOrigin, 
  CleartextLoggingFlow::PathNode loggingSink, 
  string dataSensitivityType
where
  // Verify data flows from source to sink without encryption
  CleartextLoggingFlow::flowPath(dataOrigin, loggingSink)
  and
  // Extract sensitivity classification from the data source
  dataSensitivityType = dataOrigin.getNode().(Source).getClassification()
select 
  // Report sink location with source context and sensitivity details
  loggingSink.getNode(), 
  dataOrigin, 
  loggingSink, 
  "This expression logs $@ as clear text.", 
  dataOrigin.getNode(),
  "sensitive data (" + dataSensitivityType + ")"