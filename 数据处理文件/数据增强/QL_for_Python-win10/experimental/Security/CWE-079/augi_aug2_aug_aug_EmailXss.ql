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

// 导入Python语言分析所需的基础库
import python

// 导入实验性电子邮件XSS数据流分析模块
import experimental.semmle.python.security.dataflow.EmailXss

// 导入用于可视化数据流路径的路径图工具
import EmailXssFlow::PathGraph

// 查找从污染源到危险汇点的数据流路径
from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
where EmailXssFlow::flowPath(sourceNode, sinkNode)

// 生成漏洞报告，包括源节点、汇节点和漏洞描述
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       sourceNode.getNode(), 
       "用户提供的值"