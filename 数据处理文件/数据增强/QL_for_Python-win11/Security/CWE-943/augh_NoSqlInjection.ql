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

// 导入Python分析库
import python
// 导入NoSQL注入数据流分析模块
import semmle.python.security.dataflow.NoSqlInjectionQuery
// 导入用于表示数据流路径的路径图类
import NoSqlInjectionFlow::PathGraph

// 定义查询起点和终点
from NoSqlInjectionFlow::PathNode startPoint, NoSqlInjectionFlow::PathNode endPoint
// 验证数据流路径存在性
where NoSqlInjectionFlow::flowPath(startPoint, endPoint)
// 输出结果：目标节点、路径起点、路径终点、警告信息、污染源、输入描述
select endPoint.getNode(), startPoint, endPoint, "This NoSQL query contains an unsanitized $@.", startPoint,
  "user-provided value"