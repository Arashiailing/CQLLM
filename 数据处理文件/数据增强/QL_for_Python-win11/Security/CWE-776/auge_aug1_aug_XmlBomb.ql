/**
 * @name XML内部实体扩展漏洞（XML Bomb）
 * @description 检测未限制内部实体扩展的XML解析代码路径，此类代码易受拒绝服务攻击（DoS）。
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

// 定义数据流分析的关键节点：用户输入源和XML解析器目标
from XmlBombFlow::PathNode userInputSource, XmlBombFlow::PathNode xmlParserSink
// 验证用户输入是否流向未防护的XML解析器
where XmlBombFlow::flowPath(userInputSource, xmlParserSink)
// 输出分析结果：目标位置、源头位置、目标位置及安全警告信息
select xmlParserSink.getNode(), userInputSource, xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  userInputSource.getNode(), "用户控制的输入源"