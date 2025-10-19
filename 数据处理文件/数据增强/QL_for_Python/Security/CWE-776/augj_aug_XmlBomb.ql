/**
 * @name XML内部实体扩展漏洞
 * @description 识别将用户可控输入传递给XML解析器且未限制内部实体扩展的代码路径，此类路径可能导致拒绝服务攻击。
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

// 定义数据流分析的源节点和汇节点
from XmlBombFlow::PathNode sourceNode, XmlBombFlow::PathNode sinkNode
// 验证从用户输入源到XML解析器的数据流路径是否存在
where XmlBombFlow::flowPath(sourceNode, sinkNode)
// 输出分析结果：目标位置、源头位置、目标位置及安全警告信息
select sinkNode.getNode(), sourceNode, sinkNode,
  "XML解析器处理了$@，但未实施适当的实体扩展限制措施。",
  sourceNode.getNode(), "用户控制的输入源"