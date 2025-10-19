/**
 * @name SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of
 *              malicious SQL code by the user.
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

// 定义查询：追踪从用户输入源到SQL查询汇点的数据流路径
from 
  // 定义数据流源节点变量
  SqlInjectionFlow::PathNode sourceNode, 
  // 定义数据流汇节点变量
  SqlInjectionFlow::PathNode sinkNode
where 
  // 验证存在从用户输入源到SQL查询汇点的完整数据流路径
  SqlInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  // 输出目标节点（SQL查询位置）
  sinkNode.getNode(), 
  // 数据流路径的起点（用户输入源）
  sourceNode, 
  // 数据流路径的终点（SQL查询汇点）
  sinkNode, 
  // 安全问题描述模板
  "This SQL query depends on a $@.", 
  // 用户输入源节点（用于问题描述）
  sourceNode.getNode(), 
  // 用户输入源描述文本
  "user-provided value"