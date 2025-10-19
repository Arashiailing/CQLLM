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

// Define query variables representing data flow source, destination, and classification
from
  CleartextLoggingFlow::PathNode sourceNode, 
  CleartextLoggingFlow::PathNode sinkNode, 
  string classificationType
where
  // Verify existence of data flow path from source to sink
  CleartextLoggingFlow::flowPath(sourceNode, sinkNode)
  and
  // Extract data classification from the source node
  classificationType = sourceNode.getNode().(Source).getClassification()
select 
  // Output results including sink node, source node, path, warning message, and classification
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression logs $@ as clear text.", 
  sourceNode.getNode(),
  "sensitive data (" + classificationType + ")"