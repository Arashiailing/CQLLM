/**
 * @name XML external entity expansion vulnerability
 * @description Identifies insecure XML parsing operations that expand external entities
 *              without implementing adequate security controls when processing 
 *              user-supplied input, potentially leading to information disclosure,
 *              server-side request forgery, or denial of service attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import core Python analysis framework for code parsing and evaluation
import python

// Import specialized modules for XML external entity (XXE) vulnerability detection
import semmle.python.security.dataflow.XxeQuery

// Import path graph utilities for tracking and visualizing data flow trajectories
import XxeFlow::PathGraph

// Define the entry point where untrusted user input originates
from XxeFlow::PathNode inputOrigin, XxeFlow::PathNode vulnerablePoint
// Verify that data flows from user input to insecure XML parsing
where XxeFlow::flowPath(inputOrigin, vulnerablePoint)
// Generate security alert with complete data flow visualization
select vulnerablePoint.getNode(), inputOrigin, vulnerablePoint,
  "XML document parsed using $@ without protections against external entity expansion.",
  inputOrigin.getNode(), "user-controlled input"