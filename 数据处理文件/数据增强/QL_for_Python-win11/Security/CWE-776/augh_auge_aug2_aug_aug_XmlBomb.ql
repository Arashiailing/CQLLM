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

// 检测XML炸弹攻击：恶意XML文档通过大量嵌套实体引用导致资源耗尽
// 当应用程序直接解析用户提供的XML内容且未限制实体扩展时，攻击者可构造特殊XML
// 这种XML在解析过程中会指数级消耗系统资源，最终导致服务不可用
// 本查询通过追踪数据流识别此类潜在漏洞点

// 从不可信输入源到易受攻击XML解析器的数据流路径分析
from XmlBombFlow::PathNode untrustedInputSource, XmlBombFlow::PathNode vulnerableXmlParser
where XmlBombFlow::flowPath(untrustedInputSource, vulnerableXmlParser)

// 输出检测结果：标记存在漏洞的XML解析点及其相关输入源
select vulnerableXmlParser.getNode(), 
       untrustedInputSource, 
       vulnerableXmlParser,
       "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
       untrustedInputSource.getNode(), 
       "用户控制的输入源"