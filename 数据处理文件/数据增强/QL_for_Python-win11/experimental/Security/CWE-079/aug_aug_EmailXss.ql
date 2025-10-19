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

// 核心Python分析引擎导入
import python

// 实验性电子邮件XSS数据流分析模块
import experimental.semmle.python.security.dataflow.EmailXss

// 路径可视化组件导入
import EmailXssFlow::PathGraph

// 定义数据流追踪：从污染源到危险汇点的完整路径
from EmailXssFlow::PathNode sourceNode, EmailXssFlow::PathNode sinkNode
where EmailXssFlow::flowPath(sourceNode, sinkNode)

// 生成漏洞报告：包含源节点、汇节点和漏洞描述
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       sourceNode.getNode(), 
       "用户提供的值"