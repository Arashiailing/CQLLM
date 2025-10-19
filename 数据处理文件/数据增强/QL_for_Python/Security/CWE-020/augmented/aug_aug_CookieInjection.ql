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

// 导入Python代码分析基础库
import python

// 导入专门处理Cookie注入安全问题的数据流模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入用于可视化数据流路径的图结构
import CookieInjectionFlow::PathGraph

// 定义数据流查询：从不可信输入源到Cookie构造点的路径
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieConstructionSink
where CookieInjectionFlow::flowPath(untrustedSource, cookieConstructionSink)
// 输出结果：包含汇节点、源节点、路径节点、描述信息和源节点类型说明
select cookieConstructionSink.getNode(), 
       untrustedSource, 
       cookieConstructionSink, 
       "Cookie is constructed from a $@.", 
       untrustedSource.getNode(),
       "user-supplied input"