/**
 * @name XML external entity expansion
 * @description Detects XML parsing operations that process user input without
 *              proper protection against external entity expansion, leading to XXE vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import Python analysis library for code parsing and analysis
import python

// Import XXE (XML External Entity) attack related query module
import semmle.python.security.dataflow.XxeQuery

// Import path graph class to represent data flow paths
import XxeFlow::PathGraph

// Define data flow source and sink nodes for XXE vulnerability analysis
from XxeFlow::PathNode userInputSource, XxeFlow::PathNode xxeVulnerableSink

// Check if there's a data flow path from user input to XML parsing sink
// This condition identifies potential XXE vulnerabilities where user-controlled input
// reaches XML parsing operations without proper sanitization
where XxeFlow::flowPath(userInputSource, xxeVulnerableSink)

// Generate results for identified XXE vulnerabilities
select xxeVulnerableSink.getNode(), userInputSource, xxeVulnerableSink,
  "XML parsing depends on a $@ without guarding against external entity expansion.", // Alert: XML parsing without protection against external entity expansion
  userInputSource.getNode(), "user-provided value" // Source node information and user input label