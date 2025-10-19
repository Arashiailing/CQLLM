/**
 * @name Clear-text logging of sensitive information
 * @description Detects cases where sensitive data is logged without encryption,
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

// Core Python analysis framework
import python
// Data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow
// Path visualization components
import CleartextLoggingFlow::PathGraph
// Specialized cleartext logging detection
import semmle.python.security.dataflow.CleartextLoggingQuery

from
  CleartextLoggingFlow::PathNode sourceNode, 
  CleartextLoggingFlow::PathNode sinkNode, 
  string classificationType
where
  // Verify data flow path exists between sensitive source and logging sink
  CleartextLoggingFlow::flowPath(sourceNode, sinkNode)
  and
  // Extract data classification from the sensitive source
  classificationType = sourceNode.getNode().(Source).getClassification()
select 
  // Report sink location with path details and classification
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression logs $@ as clear text.", 
  sourceNode.getNode(),
  "sensitive data (" + classificationType + ")"