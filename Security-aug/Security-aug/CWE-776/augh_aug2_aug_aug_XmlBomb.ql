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

/**
 * 检测XML实体扩展攻击（XML Bomb）漏洞。
 * 
 * 攻击原理：
 * 恶意用户可以构造包含大量递归实体引用的XML文档。
 * 当XML解析器尝试展开这些实体时，会指数级消耗系统资源，
 * 最终导致服务不可用，形成拒绝服务攻击。
 * 
 * 查询逻辑：
 * 1. 识别所有可能受用户控制的输入源
 * 2. 识别所有未限制实体扩展的XML解析操作
 * 3. 追踪从输入源到解析器的数据流路径
 * 4. 报告存在安全风险的代码路径
 */
from XmlBombFlow::PathNode maliciousInputSource, XmlBombFlow::PathNode xmlParserSink
where XmlBombFlow::flowPath(maliciousInputSource, xmlParserSink)
select xmlParserSink.getNode(), maliciousInputSource, xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施，可能导致拒绝服务攻击。",
  maliciousInputSource.getNode(), "恶意用户输入源"