/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 检测将未受限制的用户输入解析为XML文档的代码路径，此类代码易受XML内部实体扩展攻击，可能导致拒绝服务。
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

// 此查询专门用于识别XML实体扩展攻击（XML Bomb）漏洞
// 当应用程序解析包含大量嵌套实体引用的恶意构造XML文档时，会发生此类漏洞
// 攻击者可以设计特殊XML文档，在解析过程中消耗大量系统资源
// 这可能导致服务拒绝（DoS）或系统性能显著下降
// 查询的核心机制是追踪从不可信用户输入到XML解析器的完整数据流路径

// 定义关键变量：不可信输入源和易受攻击的XML解析点
from XmlBombFlow::PathNode untrustedInputSource, XmlBombFlow::PathNode vulnerableXmlParser

// 验证数据流：确认存在从用户输入到XML解析器的完整数据流路径
where XmlBombFlow::flowPath(untrustedInputSource, vulnerableXmlParser)

// 输出分析结果：包含漏洞位置、输入源、数据流路径及安全警告信息
select vulnerableXmlParser.getNode(), 
       untrustedInputSource, 
       vulnerableXmlParser,
       "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
       untrustedInputSource.getNode(), 
       "用户控制的输入源"