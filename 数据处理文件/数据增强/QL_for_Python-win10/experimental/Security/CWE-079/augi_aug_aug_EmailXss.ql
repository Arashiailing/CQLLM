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

// 导入Python语言分析的核心引擎
import python

// 导入实验性电子邮件XSS数据流分析库
import experimental.semmle.python.security.dataflow.EmailXss

// 导入路径图可视化支持模块
import EmailXssFlow::PathGraph

// 定义数据流追踪：识别从污染源到危险汇点的完整路径
from EmailXssFlow::PathNode taintSource, EmailXssFlow::PathNode vulnerableSink
where EmailXssFlow::flowPath(taintSource, vulnerableSink)

// 生成漏洞报告：包含源节点、汇节点和漏洞描述
select vulnerableSink.getNode(), 
       taintSource, 
       vulnerableSink, 
       "由于 $@ 导致的跨站脚本漏洞。",
       taintSource.getNode(), 
       "用户提供的值"