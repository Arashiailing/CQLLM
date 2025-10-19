/**
 * @name XML external entity expansion
 * @description Detects when user-controlled input flows into an XML parser without
 *              proper protection against external entity expansion attacks.
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

// Define tainted input source and vulnerable XML parsing sink
from XxeFlow::PathNode taintedSource, XxeFlow::PathNode vulnerableSink
// Verify data flow exists between user input and insecure XML processing
where XxeFlow::flowPath(taintedSource, vulnerableSink)

// Generate security alert with complete data flow path
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "XML document parsing uses a $@ without safeguards against external entity expansion.",
  taintedSource.getNode(), "user-controlled input"