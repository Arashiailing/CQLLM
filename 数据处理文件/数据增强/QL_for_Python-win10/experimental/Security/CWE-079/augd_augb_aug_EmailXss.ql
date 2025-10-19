/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where user-supplied data is directly
 *              rendered in web content without sanitization, enabling XSS attacks.
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

// Define vulnerability tracking: trace data from user input to dangerous output
from EmailXssFlow::PathNode userInputNode, EmailXssFlow::PathNode xssOutputNode
where 
  // Establish data flow connection between input and output
  EmailXssFlow::flowPath(userInputNode, xssOutputNode)

// Generate vulnerability report with path details
select xssOutputNode.getNode(), 
       userInputNode, 
       xssOutputNode, 
       "Cross-site scripting vulnerability caused by $@.",
       userInputNode.getNode(), 
       "User-provided value"