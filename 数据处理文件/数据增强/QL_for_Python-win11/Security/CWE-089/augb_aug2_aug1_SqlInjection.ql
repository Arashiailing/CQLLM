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

// 引入Python语言分析支持库
import python

// 引入SQL注入漏洞数据流分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 引入SQL注入路径可视化工具
import SqlInjectionFlow::PathGraph

// 查询定义：识别从用户可控输入到SQL查询构造点的数据流
from SqlInjectionFlow::PathNode inputSource, SqlInjectionFlow::PathNode sqlSink
where SqlInjectionFlow::flowPath(inputSource, sqlSink)
select 
  // 报告位置：SQL查询执行点
  sqlSink.getNode(), 
  // 数据流路径起始节点（用户输入）
  inputSource, 
  // 数据流路径终止节点（SQL查询构造）
  sqlSink, 
  // 漏洞描述模板
  "This SQL query depends on a $@.", 
  // 模板参数：用户输入源节点
  inputSource.getNode(), 
  // 用户输入源描述
  "user-provided value"