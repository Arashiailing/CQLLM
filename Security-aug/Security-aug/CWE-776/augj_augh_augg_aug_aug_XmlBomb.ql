/**
 * @name XML实体扩展拒绝服务漏洞检测
 * @description 识别未限制用户输入被解析为XML文档的代码路径，此类代码易受XML内部实体扩展攻击，
 *              可能导致系统资源耗尽并引发拒绝服务。
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

// 定义数据流分析的起点和终点变量
from XmlBombFlow::PathNode untrustedSource, XmlBombFlow::PathNode xmlParserSink

// 检查是否存在从不可信输入源到XML解析器的数据流路径
where XmlBombFlow::flowPath(untrustedSource, xmlParserSink)

// 输出漏洞分析结果，包含目标位置、源头位置及安全警告信息
select xmlParserSink.getNode(),       // 漏洞目标位置（XML解析器）
       untrustedSource,               // 漏洞源头位置（不可信输入源）
       xmlParserSink,                 // 数据流路径终点
       "XML解析器处理了一个$@，" +    // 警告消息第一部分
       "但未实施适当的实体扩展限制措施。",  // 警告消息第二部分
       untrustedSource.getNode(),     // 用于警告消息的源节点引用
       "用户控制的输入源"             // 源节点描述文本