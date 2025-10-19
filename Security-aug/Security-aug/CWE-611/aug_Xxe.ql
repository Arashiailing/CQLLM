/**
 * @name XML external entity expansion
 * @description Identifies vulnerabilities where user-supplied input is processed
 *              by an XML parser without proper security controls against external entity expansion.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import Python analysis framework for code parsing and evaluation
import python

// Import specialized XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Import path graph utilities for visualizing data flow trajectories
import XxeFlow::PathGraph

// Identify potential XXE vulnerability entry points and dangerous XML parsing locations
from XxeFlow::PathNode userInputOrigin, XxeFlow::PathNode xmlParsingLocation
// Verify data flow exists between user input and insecure XML processing
where XxeFlow::flowPath(userInputOrigin, xmlParsingLocation)

// Generate security alert with complete data flow path information
select xmlParsingLocation.getNode(), userInputOrigin, xmlParsingLocation,
  "XML document parsing utilizes a $@ without implementing safeguards against external entity expansion.", // Security alert: Unprotected XML processing
  userInputOrigin.getNode(), "user-controlled input" // Input source identification and labeling