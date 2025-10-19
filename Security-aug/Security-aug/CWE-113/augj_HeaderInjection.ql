/**
 * @name HTTP Response Splitting
 * @description Writing user input directly to an HTTP header
 *              makes code vulnerable to attack by header splitting.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// 导入Python分析库
import python

// 导入HTTP头注入查询模块
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// 导入路径图类，用于表示数据流路径
import HeaderInjectionFlow::PathGraph

// 定义数据流起始节点和目标节点
from HeaderInjectionFlow::PathNode origin, HeaderInjectionFlow::PathNode target

// 筛选存在数据流路径的节点对
where HeaderInjectionFlow::flowPath(origin, target)

// 输出目标节点、起始节点和路径信息，并附带警告消息
select target.getNode(), origin, target, "This HTTP header is constructed from a $@.", origin.getNode(),
  "user-provided value"