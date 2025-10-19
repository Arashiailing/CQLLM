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

// 定义数据流分析的源点（用户输入）和汇点（XML解析器）
from XmlBombFlow::PathNode taintedSource, XmlBombFlow::PathNode vulnerableSink
// 检查是否存在从用户输入到XML解析器的数据流路径
where XmlBombFlow::flowPath(taintedSource, vulnerableSink)
// 输出漏洞报告，包括位置、源点、汇点和警告信息
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  taintedSource.getNode(), "用户控制的输入源"