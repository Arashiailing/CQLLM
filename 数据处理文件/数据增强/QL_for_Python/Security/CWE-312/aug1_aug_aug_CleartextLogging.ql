/**
 * @name Clear-text logging of sensitive information
 * @description Identifies instances where sensitive data is being logged without encryption,
 *              which could lead to exposure of confidential information to unauthorized parties.
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

// Define query variables representing data flow components
from
  CleartextLoggingFlow::PathNode sensitiveSourceNode, 
  CleartextLoggingFlow::PathNode loggingSinkNode, 
  string dataClassification
where
  // Verify data flow path exists from sensitive source to logging sink
  CleartextLoggingFlow::flowPath(sensitiveSourceNode, loggingSinkNode)
  and
  // Extract classification type from the sensitive data source
  dataClassification = sensitiveSourceNode.getNode().(Source).getClassification()
select 
  // Output results with sink location, source node, sink node, warning message, and classification
  loggingSinkNode.getNode(), 
  sensitiveSourceNode, 
  loggingSinkNode, 
  "This expression logs $@ as clear text.", 
  sensitiveSourceNode.getNode(),
  "sensitive data (" + dataClassification + ")"