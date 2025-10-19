/**
 * @name XML外部实体扩展漏洞
 * @description 检测用户输入数据流入XML解析器且缺乏外部实体扩展防护的安全风险
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// 导入Python核心分析框架
import python

// 导入XXE漏洞专用检测模块
import semmle.python.security.dataflow.XxeQuery

// 导入用于数据流可视化的路径图工具
import XxeFlow::PathGraph

// 追踪从输入源到XML处理汇点的危险数据流
from XxeFlow::PathNode untrustedInputSource, XxeFlow::PathNode unsafeXmlSink
where 
  // 确立从不可信输入到XML解析器的传播路径
  XxeFlow::flowPath(untrustedInputSource, unsafeXmlSink)

// 报告缺乏XXE防护机制的脆弱XML解析
select unsafeXmlSink.getNode(), untrustedInputSource, unsafeXmlSink,
  "XML解析器在未启用外部实体扩展防护的情况下处理了$@。",
  untrustedInputSource.getNode(), "不可信的用户输入"