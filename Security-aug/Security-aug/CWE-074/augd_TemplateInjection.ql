/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// 导入Python语言支持库
import python
// 导入模板注入安全查询模块
import semmle.python.security.dataflow.TemplateInjectionQuery
// 导入用于表示数据流路径的路径图类
import TemplateInjectionFlow::PathGraph

// 定义数据流分析的起点和终点
from TemplateInjectionFlow::PathNode injectionSource, TemplateInjectionFlow::PathNode sinkNode
// 验证存在从用户输入到模板构造点的数据流路径
where TemplateInjectionFlow::flowPath(injectionSource, sinkNode)
// 输出漏洞位置、数据流路径和警告信息
select sinkNode.getNode(), injectionSource, sinkNode, 
  "This template construction depends on a $@.",
  injectionSource.getNode(), "user-provided value"