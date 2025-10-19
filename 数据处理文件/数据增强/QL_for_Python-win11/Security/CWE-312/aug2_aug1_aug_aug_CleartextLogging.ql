/**
 * @name Clear-text logging of sensitive information
 * @description Detects when sensitive data is logged without encryption,
 *              potentially exposing confidential information to unauthorized parties.
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
  CleartextLoggingFlow::PathNode sensitiveDataNode,  // Source of sensitive data
  CleartextLoggingFlow::PathNode logSinkNode,        // Logging destination
  string classificationType                          // Data classification label
where
  // Verify data flows from sensitive source to logging sink
  CleartextLoggingFlow::flowPath(sensitiveDataNode, logSinkNode)
  and
  // Extract classification from the sensitive data source
  classificationType = sensitiveDataNode.getNode().(Source).getClassification()
select 
  // Report findings with sink location, flow path, and classification
  logSinkNode.getNode(), 
  sensitiveDataNode, 
  logSinkNode, 
  "This expression logs $@ as clear text.", 
  sensitiveDataNode.getNode(),
  "sensitive data (" + classificationType + ")"