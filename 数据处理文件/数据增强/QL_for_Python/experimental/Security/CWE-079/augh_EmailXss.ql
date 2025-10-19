/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page
 *              allows for a cross-site scripting vulnerability.
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

// High precision query for detecting XSS vulnerabilities
import python
import experimental.semmle.python.security.dataflow.EmailXss
import EmailXssFlow::PathGraph

from EmailXssFlow::PathNode userInputNode, EmailXssFlow::PathNode outputNode
where EmailXssFlow::flowPath(userInputNode, outputNode)
select outputNode.getNode(), 
       userInputNode, 
       outputNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       userInputNode.getNode(), 
       "用户提供的值"