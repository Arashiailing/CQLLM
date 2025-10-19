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

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入与SQL注入相关的数据流分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入路径图模块，用于表示数据流路径
import SqlInjectionFlow::PathGraph

// 定义查询，查找从源节点到汇节点的数据流路径
from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink) // 条件：存在从源节点到汇节点的路径
select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(),
  "user-provided value" // 选择结果：汇节点、源节点、路径信息以及描述信息
