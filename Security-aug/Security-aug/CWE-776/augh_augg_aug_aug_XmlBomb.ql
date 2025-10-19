/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 识别未限制用户输入被解析为XML文档的代码路径，此类代码易受XML内部实体扩展攻击，
 *              可能导致系统资源耗尽并引发拒绝服务。
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

// 追踪从不可信输入源到XML解析器的数据流路径
from XmlBombFlow::PathNode maliciousInputOrigin, XmlBombFlow::PathNode vulnerableXmlParser
where XmlBombFlow::flowPath(maliciousInputOrigin, vulnerableXmlParser)
// 输出漏洞分析结果，包含目标位置、源头位置及安全警告信息
select vulnerableXmlParser.getNode(),
       maliciousInputOrigin,
       vulnerableXmlParser,
       "XML解析器处理了一个$@，" + "但未实施适当的实体扩展限制措施。",
       maliciousInputOrigin.getNode(),
       "用户控制的输入源"