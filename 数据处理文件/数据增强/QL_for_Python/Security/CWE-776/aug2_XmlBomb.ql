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

// 定义数据流的起点和终点
from XmlBombFlow::PathNode origin, XmlBombFlow::PathNode target
// 验证是否存在从起点到终点的数据流路径
where XmlBombFlow::flowPath(origin, target)
// 输出结果：目标节点、源节点、目标节点以及安全警告信息
select target.getNode(), origin, target,
  "XML解析依赖于一个$@，而没有防范不受控制的实体扩展。",
  origin.getNode(), "用户提供的值"