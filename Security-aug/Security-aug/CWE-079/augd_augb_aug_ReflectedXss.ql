/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where untrusted user input is directly
 *              output to web content without adequate sanitization, allowing
 *              attackers to inject malicious scripts.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/reflective-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Import Python language library for security analysis
import python
// Import specialized module for detecting reflected cross-site scripting vulnerabilities
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph module for visualizing data flow paths
import ReflectedXssFlow::PathGraph

// Define malicious input origin and vulnerable output point for XSS detection
from 
  ReflectedXssFlow::PathNode maliciousInputOrigin,  // Represents the source of untrusted user input
  ReflectedXssFlow::PathNode vulnerableOutputPoint  // Represents the sink where XSS can occur
// Verify data flow path from malicious input to vulnerable output
where ReflectedXssFlow::flowPath(maliciousInputOrigin, vulnerableOutputPoint)
// Generate security alert with detailed vulnerability information
select 
  vulnerableOutputPoint.getNode(),                  // Location of the vulnerable output
  maliciousInputOrigin,                             // Origin of the malicious input
  vulnerableOutputPoint,                            // Path node details
  "Cross-site scripting vulnerability caused by a $@.", // Alert message
  maliciousInputOrigin.getNode(),                  // Source node location
  "user-provided input"                             // Source description