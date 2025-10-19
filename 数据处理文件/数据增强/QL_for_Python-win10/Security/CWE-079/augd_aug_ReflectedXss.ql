/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where untrusted user inputs are
 *              directly rendered in web content without appropriate sanitization,
 *              allowing attackers to inject malicious scripts.
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

// Import essential Python language analysis libraries
import python
// Import specialized module for detecting reflected cross-site scripting vulnerabilities
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph utilities for visualizing data flow paths
import ReflectedXssFlow::PathGraph

// Main query logic: identify potential reflected XSS vulnerabilities
from 
  ReflectedXssFlow::PathNode untrustedInputSource, 
  ReflectedXssFlow::PathNode xssTargetSink
where 
  // Verify that a data flow path exists from the untrusted input to the vulnerable output
  ReflectedXssFlow::flowPath(untrustedInputSource, xssTargetSink)
select 
  // Output the vulnerable sink location
  xssTargetSink.getNode(), 
  // Include source node for path tracking
  untrustedInputSource, 
  // Include sink node for complete path information
  xssTargetSink, 
  // Generate alert message with source reference
  "Cross-site scripting vulnerability due to a $@.",
  // Reference to the source node for message
  untrustedInputSource.getNode(), 
  // Description of the source
  "user-provided value"