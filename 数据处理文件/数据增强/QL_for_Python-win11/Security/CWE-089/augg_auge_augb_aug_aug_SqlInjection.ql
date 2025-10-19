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

// 导入Python语言分析的核心组件
import python

// 导入SQL注入漏洞的数据流分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入用于路径可视化的图形表示工具
import SqlInjectionFlow::PathGraph

// 定义数据流追踪：识别从用户输入到SQL查询构建的完整数据流路径
from 
  SqlInjectionFlow::PathNode taintedSource,       // 表示用户控制的输入源节点
  SqlInjectionFlow::PathNode vulnerableSink        // 表示存在SQL注入风险的接收点节点
where 
  // 确认存在从用户输入到SQL查询的数据流
  SqlInjectionFlow::flowPath(taintedSource, vulnerableSink)
select 
  vulnerableSink.getNode(),        // 定位SQL注入漏洞的具体代码位置
  taintedSource,                   // 标识污染数据的来源节点
  vulnerableSink,                  // 标识数据流的终点（即漏洞点）
  "此SQL查询依赖于$@。",           // 漏洞描述消息模板
  taintedSource.getNode(),         // 用于消息占位符替换的源节点
  "用户提供的输入"                // 污染源的类别标签