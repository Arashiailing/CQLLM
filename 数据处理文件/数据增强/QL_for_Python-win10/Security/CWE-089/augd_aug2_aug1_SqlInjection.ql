/**
 * @name SQL query built from user-controlled sources
 * @description Detects SQL injection vulnerabilities where SQL queries are constructed
 *              using user-provided input without proper sanitization.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// 导入Python代码分析基础库
import python

// 导入SQL注入数据流分析核心模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入SQL注入路径可视化模块
import SqlInjectionFlow::PathGraph

// 定义查询：识别从用户输入源到SQL查询构造点的数据流路径
from 
  // 用户输入源节点
  SqlInjectionFlow::PathNode userInputSource, 
  // SQL查询汇点节点
  SqlInjectionFlow::PathNode querySink
where 
  // 确认存在从用户输入到SQL查询的完整数据流
  SqlInjectionFlow::flowPath(userInputSource, querySink)
select 
  // 输出SQL查询位置
  querySink.getNode(), 
  // 数据流起点（用户输入）
  userInputSource, 
  // 数据流终点（SQL查询）
  querySink, 
  // 安全问题描述
  "This SQL query depends on a $@.", 
  // 用户输入源节点引用
  userInputSource.getNode(), 
  // 用户输入源类型描述
  "user-provided value"