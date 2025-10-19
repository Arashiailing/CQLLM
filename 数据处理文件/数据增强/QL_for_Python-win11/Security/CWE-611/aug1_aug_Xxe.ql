/**
 * @name XML external entity expansion vulnerability
 * @description Detects insecure XML parsing where external entities are expanded
 *              without proper security controls when processing user-provided input.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis framework for code parsing and evaluation
import python

// Specialized modules for XML external entity (XXE) vulnerability detection
import semmle.python.security.dataflow.XxeQuery

// Path graph utilities for tracking and visualizing data flow trajectories
import XxeFlow::PathGraph

// Identify vulnerable XML processing paths from user input to parser
from XxeFlow::PathNode sourceNode, XxeFlow::PathNode sinkNode
// Confirm data flow exists between untrusted input and insecure XML processing
where XxeFlow::flowPath(sourceNode, sinkNode)

// Generate security alert with complete data flow path visualization
select sinkNode.getNode(), sourceNode, sinkNode,
  "XML document parsed using $@ without protections against external entity expansion.", // Security alert: Unsecured XML processing
  sourceNode.getNode(), "user-controlled input" // Source identification and vulnerability origin