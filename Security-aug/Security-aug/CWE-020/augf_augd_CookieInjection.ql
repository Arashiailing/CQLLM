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

// 导入Python分析基础库，提供Python代码分析的核心功能
import python

// 导入Cookie注入安全分析模块，包含Cookie注入相关的数据流定义
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入Cookie注入数据流路径图模块，用于可视化数据流路径
import CookieInjectionFlow::PathGraph

// 定义存在数据流路径的源节点和汇节点
from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode
where CookieInjectionFlow::flowPath(sourceNode, sinkNode)

// 输出结果：汇节点（Cookie构造位置）、源节点（用户输入）、路径节点、问题描述和源节点描述
select sinkNode.getNode(), sourceNode, sinkNode, "Cookie is constructed from a $@.", sourceNode.getNode(),
  "user-supplied input"