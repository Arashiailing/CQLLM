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

// Precision determined by imported data flow library
import python
import experimental.semmle.python.security.dataflow.EmailXss
import EmailXssFlow::PathGraph

from EmailXssFlow::PathNode inputNode, EmailXssFlow::PathNode outputNode
where 
  EmailXssFlow::flowPath(inputNode, outputNode)
select 
  outputNode.getNode(), 
  inputNode, 
  outputNode, 
  "由于 $@ 导致的跨站脚本漏洞。",
  inputNode.getNode(), 
  "用户提供的值"