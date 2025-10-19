/**
 * @name XML实体扩展炸弹漏洞分析
 * @description 检测将不受限的用户输入作为XML文档处理的代码路径，此类代码易受XML实体扩展攻击（也称"XML炸弹"），可能导致资源耗尽和服务拒绝。
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

// 识别XML炸弹漏洞：从不可信输入源到XML处理器的数据流
from 
  XmlBombFlow::PathNode untrustedInputOrigin,   // 不可信输入源头
  XmlBombFlow::PathNode xmlProcessingSink       // XML处理节点
where 
  // 检测是否存在从输入源到XML处理器的数据流路径
  XmlBombFlow::flowPath(untrustedInputOrigin, xmlProcessingSink)
select 
  // 输出漏洞信息，包括目标位置、源位置、路径节点以及警告描述
  xmlProcessingSink.getNode(), 
  untrustedInputOrigin, 
  xmlProcessingSink,
  "XML处理器接收到一个$@，但缺少对实体扩展的安全限制。",
  untrustedInputOrigin.getNode(), 
  "不可信的输入源"