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

// 导入核心Python分析模块
import python

// 导入实验性电子邮件XSS数据流分析模块
import experimental.semmle.python.security.dataflow.EmailXss

// 导入路径图可视化组件
import EmailXssFlow::PathGraph

// 定义查询主体：追踪从用户输入到危险输出的数据流路径
from EmailXssFlow::PathNode originNode, EmailXssFlow::PathNode vulnerableNode
where EmailXssFlow::flowPath(originNode, vulnerableNode)

// 输出漏洞报告
select vulnerableNode.getNode(), 
       originNode, 
       vulnerableNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       originNode.getNode(), 
       "用户提供的值"