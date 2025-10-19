/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 检测应用程序中未对XML实体扩展进行限制的代码路径，此类漏洞允许攻击者通过构造特制的XML文档消耗大量系统资源，导致拒绝服务攻击。
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

// 查找从不可信输入到XML处理器的数据流路径
from XmlBombFlow::PathNode taintedInputOrigin, XmlBombFlow::PathNode xmlProcessingTarget
where XmlBombFlow::flowPath(taintedInputOrigin, xmlProcessingTarget)
select xmlProcessingTarget.getNode(), taintedInputOrigin, xmlProcessingTarget,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  taintedInputOrigin.getNode(), "不可信输入源"