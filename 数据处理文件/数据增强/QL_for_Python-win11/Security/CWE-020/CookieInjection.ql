/**
 * @name Construction of a cookie using user-supplied input
 * @description Constructing cookies from user input may allow an attacker to perform a Cookie Poisoning attack.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python

// 导入与Cookie注入相关的查询模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入路径图类，用于表示数据流路径
import CookieInjectionFlow::PathGraph

// 从路径图中选择源节点和汇节点
from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where CookieInjectionFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink, "Cookie is constructed from a $@.", source.getNode(),
  "user-supplied input"
