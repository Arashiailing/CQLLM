/**
 * @name XML external entity processing vulnerability
 * @description Detects scenarios where user-supplied data is processed by an XML parser
 *              lacking proper defenses against external entity expansion attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis framework import
import python

// Specialized XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Path graph utilities for data flow visualization
import XxeFlow::PathGraph

// Define source and sink nodes for tainted data flow
from 
  XxeFlow::PathNode userInputSource,  // User-controlled input source
  XxeFlow::PathNode vulnerableXmlParser  // Vulnerable XML parsing sink
// Verify data flow path exists between input and insecure processing
where 
  XxeFlow::flowPath(userInputSource, vulnerableXmlParser)
// Generate security alert with complete flow path
select 
  vulnerableXmlParser.getNode(), 
  userInputSource, 
  vulnerableXmlParser,
  "XML document parsing uses a $@ without safeguards against external entity expansion.",
  userInputSource.getNode(), 
  "user-controlled input"