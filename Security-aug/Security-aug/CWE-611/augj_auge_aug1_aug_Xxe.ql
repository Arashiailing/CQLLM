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

// Define the source of untrusted data that could lead to XXE vulnerabilities
from XxeFlow::PathNode untrustedDataSource, XxeFlow::PathNode xmlSinkPoint
// Check if there exists a data flow path from the untrusted source to the XML parsing sink
where XxeFlow::flowPath(untrustedDataSource, xmlSinkPoint)
// Generate a security alert that shows the complete data flow path
select xmlSinkPoint.getNode(), untrustedDataSource, xmlSinkPoint,
  "XML document parsed using $@ without protections against external entity expansion.",
  untrustedDataSource.getNode(), "user-controlled input"