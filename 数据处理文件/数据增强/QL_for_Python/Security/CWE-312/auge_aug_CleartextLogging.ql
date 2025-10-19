/**
 * @name Clear-text logging of sensitive information
 * @description Identifies instances where sensitive data is logged without encryption,
 *              creating risks of unauthorized access to confidential information.
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

// Define query variables: source node, sink node, and data sensitivity classification
from
  CleartextLoggingFlow::PathNode sourceNode, 
  CleartextLoggingFlow::PathNode sinkNode, 
  string sensitivityType
where
  // Verify data flow path exists from source to sink
  CleartextLoggingFlow::flowPath(sourceNode, sinkNode)
  and
  // Extract sensitivity classification from source node
  sensitivityType = sourceNode.getNode().(Source).getClassification()
select 
  // Output sink node, source node, sink node, warning message, source node and its classification
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression logs $@ as clear text.", 
  sourceNode.getNode(),
  "sensitive data (" + sensitivityType + ")"