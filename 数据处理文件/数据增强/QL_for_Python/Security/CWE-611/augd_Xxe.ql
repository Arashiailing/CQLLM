/**
 * @name XML external entity expansion vulnerability
 * @description Detects potential XXE (XML External Entity) injection where
 *              user-supplied data is processed as XML without proper
 *              safeguards against external entity expansion.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import standard Python analysis framework
import python

// Import specialized XXE vulnerability detection module
import semmle.python.security.dataflow.XxeQuery

// Import path graph representation for data flow tracking
import XxeFlow::PathGraph

// Identify potential XXE vulnerability paths
from XxeFlow::PathNode taintedInput, XxeFlow::PathNode vulnerableSink

// Verify data flow exists from user input to XML parser
where XxeFlow::flowPath(taintedInput, vulnerableSink)

// Report vulnerability with detailed path information
select vulnerableSink.getNode(), taintedInput, vulnerableSink,
  "XML parsing consumes a $@ without proper external entity expansion protection.",
  taintedInput.getNode(), "user-controlled input"