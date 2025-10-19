/**
 * @name XML内部实体扩展漏洞
 * @description 检测将用户输入解析为XML文档时未限制内部实体扩展的代码路径，此类代码易受拒绝服务攻击。
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
from XmlBombFlow::PathNode taintedInput, XmlBombFlow::PathNode vulnerableParser
// 验证是否存在从用户输入到XML解析器的数据流路径
where XmlBombFlow::flowPath(taintedInput, vulnerableParser)
// 输出分析结果，包括目标位置、源头位置、目标位置及安全警告信息
select vulnerableParser.getNode(), taintedInput, vulnerableParser,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  taintedInput.getNode(), "用户控制的输入源"