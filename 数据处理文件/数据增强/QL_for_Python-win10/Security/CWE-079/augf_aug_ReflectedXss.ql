/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where untrusted user input is directly
 *              rendered in web responses without proper sanitization, enabling
 *              attackers to execute malicious scripts via XSS attacks.
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

// Main query to identify reflected XSS vulnerabilities
from ReflectedXssFlow::PathNode taintSource, ReflectedXssFlow::PathNode xssSink
where ReflectedXssFlow::flowPath(taintSource, xssSink)
// Select vulnerable sink with source context and path details
select xssSink.getNode(), taintSource, xssSink, 
       "Cross-site scripting vulnerability originating from a $@.",
       taintSource.getNode(), "user-provided value"