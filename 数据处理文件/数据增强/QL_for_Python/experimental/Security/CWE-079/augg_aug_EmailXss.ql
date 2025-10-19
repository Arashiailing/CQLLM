/**
 * @name Reflected server-side cross-site scripting
 * @description Detects vulnerabilities where user-supplied input is
 *              directly rendered in web pages without sanitization,
 *              enabling cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 2.9
 * @sub-severity high
 * @id py/reflective-xss-email
 * @tags security
 *       experimental
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Core Python analysis framework
import python

// Experimental data flow tracking for email-based XSS
import experimental.semmle.python.security.dataflow.EmailXss

// Path visualization components
import EmailXssFlow::PathGraph

// Identify data flow paths from untrusted input to dangerous output
from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
where EmailXssFlow::flowPath(sourceNode, sinkNode)

// Generate vulnerability report with source/sink details
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "Cross-site scripting vulnerability via $@.",
       sourceNode.getNode(), 
       "User-controlled input"