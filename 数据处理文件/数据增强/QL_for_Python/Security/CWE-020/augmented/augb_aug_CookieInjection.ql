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

// 定义不可信输入源节点和Cookie构造汇节点
from 
  CookieInjectionFlow::PathNode untrustedInputSource,  // 表示用户提供的不可信输入源
  CookieInjectionFlow::PathNode cookieConstructionSink // 表示Cookie构造点
// 验证数据流路径是否存在
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieConstructionSink)
// 输出结果：汇节点、源节点、路径信息、描述信息
select 
  cookieConstructionSink.getNode(), 
  untrustedInputSource, 
  cookieConstructionSink, 
  "Cookie is constructed from a $@.", 
  untrustedInputSource.getNode(),
  "user-supplied input"