/**
 * @name XPath query built from user-controlled sources
 * @description Building a XPath query from user-controlled sources is vulnerable to insertion of
 *              malicious Xpath code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/xpath-injection
 * @tags security
 *       external/cwe/cwe-643
 */

import python  // 导入python模块，用于分析Python代码
import semmle.python.security.dataflow.XpathInjectionQuery  // 导入Xpath注入查询模块
import XpathInjectionFlow::PathGraph  // 导入路径图模块，用于数据流分析

// 从XpathInjectionFlow模块中导入PathNode类，表示数据流路径中的节点
from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
// 使用where子句定义数据流路径的条件，即source到sink的路径
where XpathInjectionFlow::flowPath(source, sink)
// select子句选择要返回的结果，包括sink节点、source节点、路径信息等
select sink.getNode(), source, sink, "XPath expression depends on a $@.", source.getNode(),
  "user-provided value"
