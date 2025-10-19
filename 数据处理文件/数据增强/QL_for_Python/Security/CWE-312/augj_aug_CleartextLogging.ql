/**
 * @name Sensitive information exposure through clear-text logging
 * @description Identifies instances where confidential data is being logged without encryption,
 *              which could lead to unauthorized access to sensitive information.
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

// Python code analysis library import
import python
// Data flow analysis framework import
private import semmle.python.dataflow.new.DataFlow
// Path graph generation utilities import
import CleartextLoggingFlow::PathGraph
// Clear-text logging detection query import
import semmle.python.security.dataflow.CleartextLoggingQuery

// Query variables definition: source node, sink node, and sensitivity level
from CleartextLoggingFlow::PathNode sourceNode, CleartextLoggingFlow::PathNode sinkNode, string sensitivityLevel
where 
  // Verify data flow path exists from source to sink
  CleartextLoggingFlow::flowPath(sourceNode, sinkNode)
  and
  // Extract sensitivity classification from source node
  sensitivityLevel = sourceNode.getNode().(Source).getClassification()
select 
  // Output sink node, source node, sink node, warning message, source node with sensitivity level
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression logs $@ as clear text.", 
  sourceNode.getNode(),
  "sensitive data (" + sensitivityLevel + ")"