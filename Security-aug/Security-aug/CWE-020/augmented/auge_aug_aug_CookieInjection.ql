/**
 * @name 使用不可信用户输入构建Cookie
 * @description 使用用户提供的数据构建Cookie可能导致Cookie投毒漏洞。
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python分析核心框架
import python

// 用于Cookie注入检测的安全数据流分析模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 用于数据流跟踪的路径可视化组件
import CookieInjectionFlow::PathGraph

// Cookie注入漏洞的从源头到接收点的数据流跟踪
from CookieInjectionFlow::PathNode userInputSource, CookieInjectionFlow::PathNode cookieBuilderSink
where CookieInjectionFlow::flowPath(userInputSource, cookieBuilderSink)
// 结果输出：标识易受攻击的Cookie构建及其来源和流路径
select cookieBuilderSink.getNode(), 
       userInputSource, 
       cookieBuilderSink, 
       "Cookie is constructed from a $@.", 
       userInputSource.getNode(),
       "user-supplied input"