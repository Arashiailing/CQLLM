/**
 * @name XML external entity expansion vulnerability
 * @description Identifies security risks where user-provided data flows into XML parsers
 *              lacking safeguards against external entity expansion attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import core Python analysis framework
import python

// Import specialized XXE vulnerability detection modules
import semmle.python.security.dataflow.XxeQuery

// Import path graph utilities for data flow visualization
import XxeFlow::PathGraph

// Trace unsafe data flows from input sources to XML processing sinks
from XxeFlow::PathNode taintedInput, XxeFlow::PathNode vulnerableSink
where 
  // Establish propagation path from untrusted input to XML parser
  XxeFlow::flowPath(taintedInput, vulnerableSink)

// Report vulnerable XML parsing lacking XXE protection mechanisms
select vulnerableSink.getNode(), taintedInput, vulnerableSink,
  "XML parser consumes $@ without external entity expansion protection.",
  taintedInput.getNode(), "untrusted user input"