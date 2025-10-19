/**
 * @name XML内部实体扩展
 * @description 将用户输入解析为具有任意内部实体扩展的XML文档，容易受到拒绝服务攻击。
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/xml-bomb
 * @tags security
 *       external/cwe/cwe-776
 *       external/cwe/cwe-400
 */

import python
import semmle.python.security.dataflow.XmlBombQuery
import XmlBombFlow::PathGraph

// 从XmlBombFlow路径图中选择源节点和汇节点
from XmlBombFlow::PathNode source, XmlBombFlow::PathNode sink
// 条件：存在从源节点到汇节点的流动路径
where XmlBombFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇节点以及相关信息
select sink.getNode(), source, sink,
  "XML解析依赖于一个$@，而没有防范不受控制的实体扩展。",
  source.getNode(), "用户提供的值"
