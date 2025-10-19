/**
 * @name XML external entity expansion vulnerability
 * @description Identifies security risks where untrusted user input reaches XML parsers
 *              without defenses against external entity expansion attacks.
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

// Specialized XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Path graph utilities for visualizing data flow trajectories
import XxeFlow::PathGraph

// Identify insecure XML processing points where tainted input flows to vulnerable parsers
from XxeFlow::PathNode untrustedInputSource, XxeFlow::PathNode insecureXmlSink
where XxeFlow::flowPath(untrustedInputSource, insecureXmlSink)

// Generate security alert with complete data flow path information
select insecureXmlSink.getNode(), untrustedInputSource, insecureXmlSink,
  "XML document processing uses a $@ without implementing safeguards against external entity expansion.",
  untrustedInputSource.getNode(), "user-controlled input"