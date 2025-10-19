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

// 导入Python语言分析支持库
import python

// 导入电子邮件XSS漏洞数据流分析实验模块
import experimental.semmle.python.security.dataflow.EmailXss

// 导入路径图生成工具，用于可视化数据流
import EmailXssFlow::PathGraph

// 查询从污染源到危险汇点的数据流路径
from EmailXssFlow::PathNode entryPointNode, EmailXssFlow::PathNode vulnerablePointNode
where EmailXssFlow::flowPath(entryPointNode, vulnerablePointNode)

// 输出漏洞报告，包含源节点、汇节点和漏洞描述
select vulnerablePointNode.getNode(), 
       entryPointNode, 
       vulnerablePointNode, 
       "由于 $@ 导致的跨站脚本漏洞。",
       entryPointNode.getNode(), 
       "用户提供的值"