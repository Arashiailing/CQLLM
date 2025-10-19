/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 识别将未受限制的用户输入解析为XML文档的代码路径，此类代码存在XML内部实体扩展攻击风险，可能导致拒绝服务。
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

// 定义数据流分析的起点（用户输入源）和终点（XML解析器）
from XmlBombFlow::PathNode userInputSource, XmlBombFlow::PathNode xmlParserSink
// 验证是否存在从用户输入到XML解析器的数据流路径
where XmlBombFlow::flowPath(userInputSource, xmlParserSink)
// 输出分析结果，包含目标位置、源头位置、目标位置及安全警告信息
select xmlParserSink.getNode(), userInputSource, xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  userInputSource.getNode(), "用户控制的输入源"