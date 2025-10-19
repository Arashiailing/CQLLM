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

// 获取数据流起点和终点
from XmlBombFlow::PathNode sourceNode, XmlBombFlow::PathNode sinkNode
// 验证从起点到终点的数据流路径存在
where XmlBombFlow::flowPath(sourceNode, sinkNode)
// 输出结果：目标节点、源节点、目标节点及安全警告信息
select sinkNode.getNode(), sourceNode, sinkNode,
  "XML解析依赖于一个$@，而没有防范不受控制的实体扩展。",
  sourceNode.getNode(), "用户提供的值"