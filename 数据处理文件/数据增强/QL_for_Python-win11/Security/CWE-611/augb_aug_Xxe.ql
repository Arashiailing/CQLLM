/**
 * @name XML external entity expansion vulnerability
 * @description Detects security flaws where untrusted user input flows into XML parsers
 *              lacking proper protections against external entity expansion attacks.
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

// Identify vulnerable XML processing locations where tainted input reaches insecure parsers
from XxeFlow::PathNode taintedInputSource, XxeFlow::PathNode vulnerableXmlSink
// Verify data flow propagation from untrusted input to dangerous XML processing
where XxeFlow::flowPath(taintedInputSource, vulnerableXmlSink)

// Generate security alert with complete data flow path information
select vulnerableXmlSink.getNode(), taintedInputSource, vulnerableXmlSink,
  "XML document processing uses a $@ without implementing safeguards against external entity expansion.", // Security alert: Unprotected XML processing
  taintedInputSource.getNode(), "user-controlled input" // Input source identification and labeling