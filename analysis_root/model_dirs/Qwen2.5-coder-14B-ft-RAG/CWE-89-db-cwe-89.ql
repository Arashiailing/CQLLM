/**
 * @name CWE-89: SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of malicious SQL code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/db-cwe-89
 * @tags security
 *       external/cwe/cwe-089
 */

// 导入Python库
import python

// 导入SQL注入数据流查询模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入路径图模块
import SqlInjectionFlow::PathGraph

// 定义查询变量：数据流源节点、数据流汇节点
from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink

// 查询条件：判断是否存在从源节点到汇节点的数据流路径
where SqlInjectionFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、汇节点、警告信息及源节点信息
select sink.getNode(), source, sink,
  "This SQL query depends on a $@.", source.getNode(), "user-provided value"