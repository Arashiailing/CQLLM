/**
 * @name 反射型跨站脚本漏洞（邮件上下文）
 * @description 将用户输入直接输出到网页会导致跨站脚本漏洞。
 *              本查询专注于邮件上下文中的反射型XSS。
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

// 检测邮件上下文中的反射型跨站脚本漏洞
import python
import experimental.semmle.python.security.dataflow.EmailXss
import EmailXssFlow::PathGraph

from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
where EmailXssFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       sourceNode.getNode(), 
       "用户输入"