/**
 * @name Clear-text logging of sensitive information
 * @description Detects sensitive data being logged without encryption,
 *              exposing confidential information to unauthorized access.
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

// Define query variables: origin point, destination point, and data classification
from
  CleartextLoggingFlow::PathNode originPoint, 
  CleartextLoggingFlow::PathNode destinationPoint, 
  string dataClassification
where
  // Validate data flow path exists between origin and destination
  CleartextLoggingFlow::flowPath(originPoint, destinationPoint)
  and
  // Extract sensitivity classification from origin point
  dataClassification = originPoint.getNode().(Source).getClassification()
select 
  // Output destination node, origin point, destination point, warning message, origin node and its classification
  destinationPoint.getNode(), 
  originPoint, 
  destinationPoint, 
  "This expression logs $@ as clear text.", 
  originPoint.getNode(),
  "sensitive data (" + dataClassification + ")"