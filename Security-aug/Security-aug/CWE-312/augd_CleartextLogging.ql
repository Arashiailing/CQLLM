/**
 * @name Clear-text logging of sensitive information
 * @description Detects when sensitive data is logged without proper encryption,
 *              potentially exposing it to unauthorized access.
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
// Import data flow analysis capabilities
private import semmle.python.dataflow.new.DataFlow
// Import path graph for visualization
import CleartextLoggingFlow::PathGraph
// Import cleartext logging detection logic
import semmle.python.security.dataflow.CleartextLoggingQuery

// Define variables for tracking sensitive data flow
from
  CleartextLoggingFlow::PathNode dataOrigin, 
  CleartextLoggingFlow::PathNode logPoint, 
  string dataType
where
  // Verify data flows from source to logging destination
  CleartextLoggingFlow::flowPath(dataOrigin, logPoint) and
  // Extract the classification of sensitive data
  dataType = dataOrigin.getNode().(Source).getClassification()
select 
  // Report the logging location with contextual information
  logPoint.getNode(), dataOrigin, logPoint, 
  "This expression logs $@ as clear text.", 
  dataOrigin.getNode(),
  "sensitive data (" + dataType + ")"