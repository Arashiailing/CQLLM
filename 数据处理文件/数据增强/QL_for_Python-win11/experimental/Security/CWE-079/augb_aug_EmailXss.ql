/**
 * @name Reflected server-side cross-site scripting
 * @description Detects vulnerabilities where user input is directly written
 *              to web pages without proper sanitization, enabling XSS attacks.
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

// Core Python analysis module import
import python

// Experimental email XSS data flow analysis module
import experimental.semmle.python.security.dataflow.EmailXss

// Path graph visualization component
import EmailXssFlow::PathGraph

// Define query logic: Track data flow from user input to dangerous output
from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
where EmailXssFlow::flowPath(sourceNode, sinkNode)

// Generate vulnerability report
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "Cross-site scripting vulnerability caused by $@.",
       sourceNode.getNode(), 
       "User-provided value"