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

// Define source and sink nodes for XSS vulnerability detection
from 
  ReflectedXssFlow::PathNode untrustedInputSource,  // Represents the origin of untrusted user input
  ReflectedXssFlow::PathNode xssSinkPoint           // Represents the vulnerable output point
// Verify data flow from untrusted input to XSS sink
where ReflectedXssFlow::flowPath(untrustedInputSource, xssSinkPoint)
// Generate alert with sink location, source information, and path details
select 
  xssSinkPoint.getNode(),                           // The vulnerable sink location
  untrustedInputSource,                             // The source of untrusted input
  xssSinkPoint,                                     // Path node information
  "Cross-site scripting vulnerability caused by a $@.", // Alert message
  untrustedInputSource.getNode(),                   // Source node location
  "user-provided input"                             // Source description