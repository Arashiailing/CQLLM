/**
 * @name SQL query constructed from user-controlled input
 * @description Building SQL statements with user-controlled data allows attackers
 *              to execute arbitrary SQL commands, leading to SQL injection flaws.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// 引入 Python 语言分析的核心组件
import python

// 引入 SQL 注入漏洞的数据流分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 引入用于路径可视化的图形表示工具
import SqlInjectionFlow::PathGraph

// 定义数据流追踪：识别从用户输入到 SQL 查询构建的完整数据流路径
from 
  SqlInjectionFlow::PathNode userControlledSource,  // 表示用户控制的输入源节点
  SqlInjectionFlow::PathNode sqlInjectionPoint     // 表示存在 SQL 注入风险的接收点节点
where 
  // 确认存在从用户输入到 SQL 查询的数据流
  SqlInjectionFlow::flowPath(userControlledSource, sqlInjectionPoint)
select 
  sqlInjectionPoint.getNode(),   // 定位 SQL 注入漏洞的具体代码位置
  userControlledSource,          // 标识污染数据的来源节点
  sqlInjectionPoint,             // 标识数据流的终点（即漏洞点）
  "此 SQL 查询依赖于 $@。",      // 漏洞描述消息模板
  userControlledSource.getNode(), // 用于消息占位符替换的源节点
  "用户提供的输入"              // 污染源的类别标签