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

// 引入Python代码分析基础库
import python
// 引入NoSQL注入数据流分析模块
import semmle.python.security.dataflow.NoSqlInjectionQuery
// 引入路径图可视化支持模块
import NoSqlInjectionFlow::PathGraph

// 声明查询变量：污染源和污染汇
from NoSqlInjectionFlow::PathNode taintedSource, NoSqlInjectionFlow::PathNode vulnerableSink
// 设置数据流条件：验证从污染源到污染汇存在完整数据流路径
where NoSqlInjectionFlow::flowPath(taintedSource, vulnerableSink)
// 输出分析结果：包含漏洞位置、数据流路径和详细警告信息
select vulnerableSink.getNode(), taintedSource, vulnerableSink, "This NoSQL query contains an unsanitized $@.", taintedSource,
  "user-provided value"