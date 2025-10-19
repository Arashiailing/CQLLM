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

// 从路径图中选择不可信输入源节点和Cookie构造汇节点
from CookieInjectionFlow::PathNode taintedSource, CookieInjectionFlow::PathNode cookieSink
where CookieInjectionFlow::flowPath(taintedSource, cookieSink)
// 选择结果：汇节点、源节点、路径信息、描述信息等
select cookieSink.getNode(), taintedSource, cookieSink, "Cookie is constructed from a $@.", taintedSource.getNode(),
  "user-supplied input"