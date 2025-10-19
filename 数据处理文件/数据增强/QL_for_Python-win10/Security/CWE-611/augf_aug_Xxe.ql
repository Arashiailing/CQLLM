/**
 * @name XML external entity expansion (XXE) vulnerability
 * @description Detects insecure XML processing where user-controlled input 
 *              is parsed without protections against external entity expansion.
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

// Define vulnerability source (user input) and sink (XML parsing location)
from XxeFlow::PathNode taintedSource, XxeFlow::PathNode vulnerableSink
// Verify data flow propagation from user input to XML processor
where XxeFlow::flowPath(taintedSource, vulnerableSink)

// Generate security alert with complete attack path
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "XML parsing operation uses $@ without external entity expansion protections.", // Alert: Unsecured XML processing
  taintedSource.getNode(), "user-controlled input source" // Source identification