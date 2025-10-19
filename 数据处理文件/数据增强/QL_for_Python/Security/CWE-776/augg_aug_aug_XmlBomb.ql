/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 探测未限制用户输入被解析为XML文档的代码路径，这些代码易受XML内部实体扩展攻击，可能引发系统拒绝服务。
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

// 查询从未经信任的输入源流向XML解析器的数据流路径
from XmlBombFlow::PathNode untrustedInputSource, XmlBombFlow::PathNode xmlParsingSink
where XmlBombFlow::flowPath(untrustedInputSource, xmlParsingSink)
// 输出分析结果，包含目标位置、源头位置、目标位置及安全警告信息
select xmlParsingSink.getNode(), untrustedInputSource, xmlParsingSink,
  "XML解析器处理了一个$@，但未实施适当的实体扩展限制措施。",
  untrustedInputSource.getNode(), "用户控制的输入源"