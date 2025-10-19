/**
 * @name Reflected server-side cross-site scripting
 * @description Detects security vulnerabilities where untrusted user-supplied data
 *              is directly rendered in web content without proper sanitization,
 *              enabling attackers to execute malicious scripts in victims' browsers.
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

// Import necessary modules for XSS vulnerability detection
import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

// Define source and sink nodes for XSS vulnerability analysis
from 
  ReflectedXssFlow::PathNode maliciousInputOrigin,  // Entry point of untrusted user data
  ReflectedXssFlow::PathNode xssVulnerableSink      // Location where data is unsafely output

// Verify data flow from untrusted input to vulnerable sink
where ReflectedXssFlow::flowPath(maliciousInputOrigin, xssVulnerableSink)

// Generate security alert with detailed vulnerability information
select 
  xssVulnerableSink.getNode(),                      // Location of the vulnerable sink
  maliciousInputOrigin,                             // Source of the untrusted input
  xssVulnerableSink,                                // Path node information
  "Cross-site scripting vulnerability caused by a $@.", // Alert message
  maliciousInputOrigin.getNode(),                   // Source node location
  "user-provided input"                             // Source description