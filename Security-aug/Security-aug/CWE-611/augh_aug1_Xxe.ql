/**
 * @name XML external entity expansion vulnerability
 * @description Detects unsafe XML parsing where untrusted input flows
 *              into XML processors without XXE protection mechanisms.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis libraries
import python

// XXE-specific security analysis components
import semmle.python.security.dataflow.XxeQuery

// Path graph representation for data flow tracking
import XxeFlow::PathGraph

// Identify vulnerable XML processing flows
from XxeFlow::PathNode untrustedSource, XxeFlow::PathNode xmlSink
where XxeFlow::flowPath(untrustedSource, xmlSink)

// Report XXE vulnerability with data flow path
select xmlSink.getNode(), untrustedSource, xmlSink,
  "XML processor handles $@ without external entity expansion protection.",
  untrustedSource.getNode(), "untrusted input source"