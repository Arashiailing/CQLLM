/**
 * @name XML内部实体扩展漏洞
 * @description 识别将用户输入解析为XML文档时未限制内部实体扩展的代码路径，此类缺陷可能导致拒绝服务攻击。
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

// 定义数据流分析中的污染源和危险汇点
from XmlBombFlow::PathNode untrustedInput, XmlBombFlow::PathNode unsafeXmlParser
// 验证从用户输入到XML解析器的完整数据流路径
where XmlBombFlow::flowPath(untrustedInput, unsafeXmlParser)
// 输出分析结果：目标位置、污染源位置、目标位置及漏洞描述
select unsafeXmlParser.getNode(), untrustedInput, unsafeXmlParser,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  untrustedInput.getNode(), "用户控制的输入源"