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

// 导入Cookie注入安全检测专用模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入数据流路径可视化工具
import CookieInjectionFlow::PathGraph

// 定义数据流路径查询的起点和终点
from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode

// 检测是否存在从用户输入到Cookie构造的数据流路径
where CookieInjectionFlow::flowPath(sourceNode, sinkNode)

// 输出检测结果：包含路径终点、起点、路径信息及安全描述
select sinkNode.getNode(), sourceNode, sinkNode, 
       "Cookie is constructed from a $@.", sourceNode.getNode(), 
       "user-supplied input"