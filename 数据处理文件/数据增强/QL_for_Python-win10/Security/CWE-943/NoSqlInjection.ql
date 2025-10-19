/**
 * @name NoSQL Injection
 * @description Building a NoSQL query from user-controlled sources is vulnerable to insertion of
 *              malicious NoSQL code by the user.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @id py/nosql-injection
 * @tags security
 *       external/cwe/cwe-943
 */

// 导入Python库，用于分析Python代码
import python
// 导入NoSQL注入查询模块
import semmle.python.security.dataflow.NoSqlInjectionQuery
// 导入路径图类，用于表示数据流路径
import NoSqlInjectionFlow::PathGraph

// 从路径图中选择源节点和汇节点
from NoSqlInjectionFlow::PathNode source, NoSqlInjectionFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where NoSqlInjectionFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、汇节点、警告信息、源节点、用户输入值描述
select sink.getNode(), source, sink, "This NoSQL query contains an unsanitized $@.", source,
  "user-provided value"
