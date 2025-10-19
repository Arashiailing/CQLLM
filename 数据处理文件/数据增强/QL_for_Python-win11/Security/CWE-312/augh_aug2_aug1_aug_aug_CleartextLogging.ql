/**
 * @name Clear-text logging of sensitive information
 * @description Identifies instances where confidential data is transmitted to logging mechanisms
 *              without encryption, creating potential exposure risks for sensitive information.
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
  CleartextLoggingFlow::PathNode sensitiveSourceNode,  // Origin point of sensitive data
  CleartextLoggingFlow::PathNode loggingSinkNode,      // Destination logging mechanism
  string dataClassificationLabel                       // Category of sensitive data
where
  // Extract classification from the sensitive data source
  dataClassificationLabel = sensitiveSourceNode.getNode().(Source).getClassification()
  and
  // Verify data flows from sensitive source to logging sink
  CleartextLoggingFlow::flowPath(sensitiveSourceNode, loggingSinkNode)
select 
  // Report findings with sink location, flow path, and classification
  loggingSinkNode.getNode(), 
  sensitiveSourceNode, 
  loggingSinkNode, 
  "This expression transmits $@ as clear text.", 
  sensitiveSourceNode.getNode(),
  "sensitive data (" + dataClassificationLabel + ")"