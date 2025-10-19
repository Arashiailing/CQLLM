/**
 * @name Reflected server-side cross-site scripting
 * @description Detects security vulnerabilities where untrusted user-supplied data 
 *              is directly rendered in web content without proper validation or 
 *              encoding, enabling attackers to execute arbitrary scripts in victims' browsers.
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

// Import core Python language support for security analysis
import python
// Import specialized library for reflected cross-site scripting detection
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path visualization module for data flow tracking
import ReflectedXssFlow::PathGraph

// Define the origin point of potentially malicious user input
from ReflectedXssFlow::PathNode maliciousInputSource,
     // Define the vulnerable output point where XSS can occur
     ReflectedXssFlow::PathNode xssVulnerableSink
// Establish data flow connection between input source and output sink
where ReflectedXssFlow::flowPath(maliciousInputSource, xssVulnerableSink)
// Generate security alert with vulnerability details and flow path
select xssVulnerableSink.getNode(),      // Location of the vulnerable sink
       maliciousInputSource,             // Origin of the untrusted input
       xssVulnerableSink,                // Path node information
       "Cross-site scripting vulnerability caused by a $@.", // Alert message
       maliciousInputSource.getNode(),   // Source node location
       "user-provided input"             // Description of the source