/**
 * @name XML external entity expansion vulnerability
 * @description Detects security vulnerabilities where untrusted user input
 *              flows into XML parsers without adequate protection against
 *              external entity expansion attacks.
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

// Define source and sink nodes for XXE vulnerability detection
from 
  XxeFlow::PathNode taintedDataSource,     // Represents the origin of untrusted user input
  XxeFlow::PathNode vulnerableXmlSink      // Represents the vulnerable XML processing point

// Verify data flow propagation from tainted input to vulnerable XML processing
where 
  XxeFlow::flowPath(taintedDataSource, vulnerableXmlSink)

// Generate security alert with complete data flow path information
select 
  vulnerableXmlSink.getNode(),     // Location of the vulnerable XML processing
  taintedDataSource,               // Source node in the data flow graph
  vulnerableXmlSink,              // Sink node in the data flow graph
  "XML document processing uses a $@ without implementing safeguards against external entity expansion.", // Security alert: Unprotected XML processing
  taintedDataSource.getNode(),     // Location of the untrusted input source
  "user-controlled input"          // Label identifying the input source