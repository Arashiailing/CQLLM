/**
 * @name XML内部实体扩展漏洞（XML Bomb）
 * @description 识别在解析XML文档时未对内部实体扩展施加限制的代码路径，
 *              此类漏洞可能导致资源耗尽型拒绝服务攻击（DoS）。
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

// 查询从污染输入源到易受攻击XML接收点的数据流路径
from XmlBombFlow::PathNode taintedInputSource, XmlBombFlow::PathNode vulnerableXmlSink
where 
  // 验证是否存在未受控的数据流路径
  XmlBombFlow::flowPath(taintedInputSource, vulnerableXmlSink)
select 
  // 输出分析结果：目标位置、源头位置、目标位置及安全警告信息
  vulnerableXmlSink.getNode(), taintedInputSource, vulnerableXmlSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  taintedInputSource.getNode(), "用户控制的输入源"