/**
 * @name XML external entity expansion vulnerability
 * @description Identifies security weaknesses where untrusted data is processed by XML parsers
 *              without adequate defenses against external entity expansion attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Fundamental Python analysis infrastructure for source code examination
import python

// Specialized modules for XXE vulnerability detection and analysis
import semmle.python.security.dataflow.XxeQuery

// Visualization components for tracking data flow paths
import XxeFlow::PathGraph

// Locate insecure XML processing points where untrusted data reaches vulnerable parsers
from XxeFlow::PathNode untrustedDataSource, XxeFlow::PathNode insecureXmlProcessor
where XxeFlow::flowPath(untrustedDataSource, insecureXmlProcessor)

// Construct security warning with complete data flow trajectory
select insecureXmlProcessor.getNode(), untrustedDataSource, insecureXmlProcessor,
  "XML document processing utilizes a $@ without implementing " +
  "proper security measures to prevent external entity expansion.", // Alert: Insecure XML handling
  untrustedDataSource.getNode(), "user-controlled input" // Source identification and classification