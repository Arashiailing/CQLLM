/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 检测未限制XML实体扩展的代码路径，攻击者可通过特制XML文档消耗系统资源导致拒绝服务
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

// 检测从不可信数据源到XML解析器的数据流路径
from XmlBombFlow::PathNode untrustedDataSource, XmlBombFlow::PathNode vulnerableXmlProcessor
where XmlBombFlow::flowPath(untrustedDataSource, vulnerableXmlProcessor)
select vulnerableXmlProcessor.getNode(), untrustedDataSource, vulnerableXmlProcessor,
  "XML解析器处理了$@，但未实施实体扩展限制措施。",
  untrustedDataSource.getNode(), "不可信数据源"