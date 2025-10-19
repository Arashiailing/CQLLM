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

// Define source and sink nodes for XXE vulnerability detection
from XxeFlow::PathNode taintedSource, XxeFlow::PathNode vulnerableSink
// Establish data flow relationship between user input and XML processing
where XxeFlow::flowPath(taintedSource, vulnerableSink)

// Generate security alert with complete data flow path information
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "XML document parsing utilizes a $@ without implementing safeguards against external entity expansion.",
  taintedSource.getNode(), "user-controlled input"