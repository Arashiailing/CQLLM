/**
 * @name Cookie constructed from user-controlled data
 * @description Creating cookies with data provided by the user can lead to Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python基础库，支持Python代码分析
import python

// 导入Cookie注入分析模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入数据流路径图模块
import CookieInjectionFlow::PathGraph

// 从路径图中选取数据流起点和终点
from CookieInjectionFlow::PathNode originNode, CookieInjectionFlow::PathNode targetNode

// 条件：数据流从起点流向终点
where CookieInjectionFlow::flowPath(originNode, targetNode)

// 输出：终点节点、起点节点、路径信息、问题描述等
select targetNode.getNode(), originNode, targetNode, "Cookie is constructed from a $@.", originNode.getNode(),
  "user-supplied input"