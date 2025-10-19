/**
 * @name XML external entity expansion vulnerability
 * @description Identifies security vulnerabilities where untrusted user input
 *              reaches XML parsers without proper protection against external
 *              entity expansion attacks.
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

// Identify vulnerable XML processing points where tainted input reaches insecure parsers
from 
  XxeFlow::PathNode untrustedInputOrigin, 
  XxeFlow::PathNode insecureXmlProcessingPoint
where 
  // Verify data flow propagation from untrusted input to dangerous XML processing
  XxeFlow::flowPath(untrustedInputOrigin, insecureXmlProcessingPoint)

// Generate security alert with complete data flow path information
select 
  insecureXmlProcessingPoint.getNode(), 
  untrustedInputOrigin, 
  insecureXmlProcessingPoint,
  "XML document processing uses a $@ without implementing safeguards against external entity expansion.", // Security alert: Unprotected XML processing
  untrustedInputOrigin.getNode(), 
  "user-controlled input" // Input source identification and labeling