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

// 本查询用于检测XML实体扩展攻击（XML Bomb）漏洞
// 此类漏洞发生在应用程序解析包含大量实体引用的恶意XML文档时
// 攻击者可构造特殊XML文档，导致解析时消耗大量系统资源
// 最终可能引发服务拒绝（DoS）或系统性能严重下降
// 查询核心逻辑是追踪从用户输入到XML解析器的完整数据流路径

// 定义查询变量：外部用户输入和XML解析处理点
from XmlBombFlow::PathNode externalUserInput, XmlBombFlow::PathNode xmlProcessingPoint

// 验证数据流路径：确认存在从用户输入到XML解析器的数据流
where XmlBombFlow::flowPath(externalUserInput, xmlProcessingPoint)

// 输出分析结果：包含漏洞位置、输入源、路径及安全警告信息
select xmlProcessingPoint.getNode(), 
       externalUserInput, 
       xmlProcessingPoint,
       "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
       externalUserInput.getNode(), 
       "用户控制的输入源"