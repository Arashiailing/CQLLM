/**
 * @name XML external entity expansion vulnerability
 * @description Identifies unsafe XML processing where untrusted input
 *              is parsed without protection against XXE attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis libraries
import python

// XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Path graph for tracking data flow paths
import XxeFlow::PathGraph

// Identify vulnerable XML processing flows
from XxeFlow::PathNode userInputNode, XxeFlow::PathNode xmlProcessingNode
where XxeFlow::flowPath(userInputNode, xmlProcessingNode)

// Report vulnerable XML parsing without XXE mitigation
select xmlProcessingNode.getNode(), userInputNode, xmlProcessingNode,
  "XML parsing processes $@ without external entity expansion protection.",
  userInputNode.getNode(), "user-controlled input"