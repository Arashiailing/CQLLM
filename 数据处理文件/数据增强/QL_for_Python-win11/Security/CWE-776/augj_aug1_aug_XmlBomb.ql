/**
 * @name XML内部实体扩展漏洞（XML Bomb）
 * @description 识别在解析XML文档时未限制内部实体扩展的代码路径，此类漏洞可被利用实施拒绝服务攻击（DoS）。
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

// 查询从用户输入源到XML解析器的数据流路径，检测未限制实体扩展的安全漏洞
from XmlBombFlow::PathNode inputSource, XmlBombFlow::PathNode xmlParserSink
where XmlBombFlow::flowPath(inputSource, xmlParserSink)
select xmlParserSink.getNode(), inputSource, xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  inputSource.getNode(), "用户控制的输入源"