/**
 * @name XML external entity expansion
 * @description Detects when user-controlled input flows to XML parsers without
 *              proper protections against XXE (XML External Entity) attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

import python
import semmle.python.security.dataflow.XxeQuery
import XxeFlow::PathGraph

from XxeFlow::PathNode sourceNode, XxeFlow::PathNode sinkNode
where XxeFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode,
  "XML parsing operation consumes $@ without XXE protection.",
  sourceNode.getNode(), "user-controlled input"