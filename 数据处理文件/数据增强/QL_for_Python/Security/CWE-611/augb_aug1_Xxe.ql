/**
 * @name XML external entity expansion vulnerability
 * @description Detects unsafe XML parsing where user-provided data
 *              is processed without protection against external entities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import core Python analysis libraries
import python

// Import XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Import path graph for tracking data flow
import XxeFlow::PathGraph

// Identify vulnerable XML processing flows
from XxeFlow::PathNode sourceNode, XxeFlow::PathNode sinkNode
where XxeFlow::flowPath(sourceNode, sinkNode)

// Report vulnerable XML parsing without XXE mitigation
select sinkNode.getNode(), sourceNode, sinkNode,
  "XML parsing processes $@ without external entity expansion protection.",
  sourceNode.getNode(), "user-controlled input"