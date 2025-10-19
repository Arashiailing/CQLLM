/**
 * @name XML external entity expansion vulnerability
 * @description Detects security flaws where untrusted data flows to XML parsers
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

// Core Python analysis framework for source code security inspection
import python

// Specialized components for XXE vulnerability detection and flow analysis
import semmle.python.security.dataflow.XxeQuery

// Path visualization utilities for tracking data propagation trajectories
import XxeFlow::PathGraph

// Identify vulnerable XML processing points where tainted data reaches insecure parsers
from XxeFlow::PathNode taintedInputSource, XxeFlow::PathNode vulnerableXmlSink
where XxeFlow::flowPath(taintedInputSource, vulnerableXmlSink)

// Generate security alert with complete data flow propagation chain
select vulnerableXmlSink.getNode(), taintedInputSource, vulnerableXmlSink,
  "XML document processing uses a $@ without implementing " +
  "adequate security controls against external entity expansion.", // Alert: Insecure XML handling
  taintedInputSource.getNode(), "untrusted user input" // Source identification and classification