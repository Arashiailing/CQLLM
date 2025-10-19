/**
 * @name SQL query built from user-controlled sources
 * @description Constructing SQL queries using user-controlled input allows attackers to inject
 *              malicious SQL code through crafted input, leading to potential data breaches.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// 导入Python语言分析支持库
import python

// 导入SQL注入漏洞数据流分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入SQL注入路径可视化工具
import SqlInjectionFlow::PathGraph

// 查询定义：检测从用户可控输入源到SQL查询执行点的数据流路径
from SqlInjectionFlow::PathNode userInputSource, SqlInjectionFlow::PathNode sqlExecutionPoint
where SqlInjectionFlow::flowPath(userInputSource, sqlExecutionPoint)
select 
  // 报告位置：SQL查询执行点
  sqlExecutionPoint.getNode(), 
  // 数据流起始节点（用户输入）
  userInputSource, 
  // 数据流终止节点（SQL查询构造）
  sqlExecutionPoint, 
  // 漏洞描述信息模板
  "This SQL query depends on a $@.", 
  // 模板参数引用：用户输入源节点
  userInputSource.getNode(), 
  // 用户输入源类型描述
  "user-provided value"