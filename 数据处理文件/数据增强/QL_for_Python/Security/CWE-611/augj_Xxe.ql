/**
 * @name XML external entity expansion
 * @description Detects potential XXE (XML External Entity) injection vulnerabilities
 *              where untrusted user input is processed as XML without proper
 *              security configurations to prevent external entity expansion.
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

// Import specialized XXE vulnerability detection modules for Python
import semmle.python.security.dataflow.XxeQuery

// Import path graph representation for visualizing data flow trajectories
import XxeFlow::PathGraph

// Define untrusted input sources and vulnerable XML parsing points
from XxeFlow::PathNode untrustedInput, XxeFlow::PathNode xmlParsingPoint

// Verify existence of data flow path from untrusted input to XML parsing operation
where XxeFlow::flowPath(untrustedInput, xmlParsingPoint)

// Select the vulnerable XML parsing location, trace back to untrusted input source,
// and generate detailed security alert with contextual information
select xmlParsingPoint.getNode(), untrustedInput, xmlParsingPoint,
  "XML parsing operation consumes a $@ without implementing security controls against external entity expansion.",
  untrustedInput.getNode(), "user-provided input"