/**
 * @name Reflected server-side cross-site scripting
 * @description Direct output of user-supplied data to web pages
 *              creates cross-site scripting vulnerabilities.
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

// Experimental email XSS dataflow analysis module
import experimental.semmle.python.security.dataflow.EmailXss

// Path visualization components
import EmailXssFlow::PathGraph

// Identify vulnerable data flow paths
from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
// Track data flow from user input to dangerous output
where EmailXssFlow::flowPath(sourceNode, sinkNode)

// Generate vulnerability report
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "Cross-site scripting vulnerability via $@.",
       sourceNode.getNode(), 
       "User-controlled input"