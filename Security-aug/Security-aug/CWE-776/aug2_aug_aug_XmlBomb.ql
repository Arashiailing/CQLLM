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

// 查询目标：追踪从不可信输入源到XML解析器的数据流路径
// 这种路径可能导致XML实体扩展攻击(也称为XML Bomb攻击)
from XmlBombFlow::PathNode untrustedInputSource, XmlBombFlow::PathNode xmlParsingSink
// 确认存在从用户输入到XML解析器的数据流
where XmlBombFlow::flowPath(untrustedInputSource, xmlParsingSink)
// 输出分析结果，包括目标位置、源位置、目标位置及安全警告信息
select xmlParsingSink.getNode(), untrustedInputSource, xmlParsingSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  untrustedInputSource.getNode(), "用户控制的输入源"