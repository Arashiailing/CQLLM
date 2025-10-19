/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where unvalidated user input is directly
 *              rendered in web content, creating opportunities for XSS exploits.
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

// Fundamental Python analysis capabilities import
import python

// Specialized email cross-site scripting flow analysis module
import experimental.semmle.python.security.dataflow.EmailXss

// Visualization component for data flow paths
import EmailXssFlow::PathGraph

// Identify vulnerable data flows: from user-controlled input to unsafe output
from EmailXssFlow::PathNode originNode, EmailXssFlow::PathNode targetNode
where EmailXssFlow::flowPath(originNode, targetNode)

// Construct security vulnerability finding report
select targetNode.getNode(), 
       originNode, 
       targetNode, 
       "Cross-site scripting vulnerability caused by $@.",
       originNode.getNode(), 
       "User-provided value"