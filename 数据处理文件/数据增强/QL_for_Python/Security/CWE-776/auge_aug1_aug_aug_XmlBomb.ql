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

// 检测XML炸弹漏洞：追踪从不可信输入源到XML处理器的数据流路径
from 
  XmlBombFlow::PathNode untrustedSource,    // 不可信输入源头
  XmlBombFlow::PathNode vulnerableXmlSink    // 存在漏洞的XML处理节点
where 
  // 验证存在从输入源到XML处理器的完整数据流路径
  XmlBombFlow::flowPath(untrustedSource, vulnerableXmlSink)
select 
  // 输出漏洞信息，包括目标位置、源位置、路径节点以及警告描述
  vulnerableXmlSink.getNode(), 
  untrustedSource, 
  vulnerableXmlSink,
  "XML处理器接收到一个$@，但缺少对实体扩展的安全限制。",
  untrustedSource.getNode(), 
  "不可信的输入源"