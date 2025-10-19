/**
 * @name Reflected server-side cross-site scripting
 * @description Detects security vulnerabilities where untrusted user input
 *              is directly rendered in web responses without sanitization,
 *              allowing attackers to inject malicious scripts via XSS attacks.
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

// Import Python language analysis framework
import python
// Import specialized module for detecting reflected cross-site scripting vulnerabilities
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph module for visualizing data flow paths
import ReflectedXssFlow::PathGraph

// Identify vulnerable data flows from untrusted inputs to web outputs
from ReflectedXssFlow::PathNode untrustedInputSource, ReflectedXssFlow::PathNode vulnerableOutputSink
where ReflectedXssFlow::flowPath(untrustedInputSource, vulnerableOutputSink)
// Report vulnerable output with source context and flow path details
select vulnerableOutputSink.getNode(), untrustedInputSource, vulnerableOutputSink, 
       "Cross-site scripting vulnerability originating from a $@.",
       untrustedInputSource.getNode(), "user-provided value"