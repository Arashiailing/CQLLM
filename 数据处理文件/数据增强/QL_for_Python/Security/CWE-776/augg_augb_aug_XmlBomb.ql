/**
 * @name XML内部实体扩展漏洞检测
 * @description 识别在解析XML文档时未对内部实体扩展实施限制的代码路径，这种缺陷可能导致拒绝服务攻击（XML Bomb）
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

// 此查询分析从用户输入到XML解析器的数据流，以检测未限制实体扩展的潜在漏洞
from XmlBombFlow::PathNode userInputSource, XmlBombFlow::PathNode xmlParserSink
where XmlBombFlow::flowPath(userInputSource, xmlParserSink)
select xmlParserSink.getNode(), userInputSource, xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  userInputSource.getNode(), "用户控制的输入源"