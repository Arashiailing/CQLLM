/**
 * @name XML内部实体扩展漏洞（XML Bomb）
 * @description 识别在解析用户提供的XML内容时未对内部实体扩展施加限制的代码模式，此类漏洞可能导致系统资源耗尽型拒绝服务攻击。
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

// 本查询旨在检测XML解析过程中的安全漏洞，重点关注未限制实体扩展的情况
// 定义数据流分析的起点（用户输入）和终点（XML解析操作）
from XmlBombFlow::PathNode userInputSource, XmlBombFlow::PathNode xmlParsingSink
// 确认存在从用户输入到XML解析器的数据流传播路径
where XmlBombFlow::flowPath(userInputSource, xmlParsingSink)
// 输出检测结果：包含漏洞位置、数据流源头、完整路径及安全警告信息
select xmlParsingSink.getNode(), userInputSource, xmlParsingSink,
  "XML解析器处理了一个$@，但未配置适当的实体扩展防护机制。",
  userInputSource.getNode(), "用户控制的输入源"