/**
 * @name XML实体扩展炸弹漏洞
 * @description 识别在解析XML文档时未对内部实体扩展施加限制的代码路径，这些路径可能导致拒绝服务攻击（XML Bomb）。
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

// 查询从不可信输入源到XML解析器的数据流路径
from XmlBombFlow::PathNode untrustedInput, XmlBombFlow::PathNode xmlParser
where XmlBombFlow::flowPath(untrustedInput, xmlParser)
// 报告漏洞详情，包括源点、汇点和风险描述
select xmlParser.getNode(), untrustedInput, xmlParser,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  untrustedInput.getNode(), "用户控制的输入源"