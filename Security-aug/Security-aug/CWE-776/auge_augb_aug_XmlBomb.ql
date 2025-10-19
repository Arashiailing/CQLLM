/**
 * @name XML内部实体扩展漏洞
 * @description 识别在解析XML文档时未对内部实体扩展进行限制的代码路径，这种配置可能导致拒绝服务攻击。
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

// 声明数据流分析中的源点（用户提供的输入）和汇点（XML解析处理点）
from XmlBombFlow::PathNode userSuppliedData, XmlBombFlow::PathNode xmlParserSink
where 
  // 确认存在从用户输入到XML解析器的数据流路径
  XmlBombFlow::flowPath(userSuppliedData, xmlParserSink)
select 
  xmlParserSink.getNode(), 
  userSuppliedData, 
  xmlParserSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  userSuppliedData.getNode(), 
  "用户控制的输入源"