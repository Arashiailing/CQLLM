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

// 导入Python语言库
import python
// 导入模板注入查询模块
import semmle.python.security.dataflow.TemplateInjectionQuery
// 导入路径图类，用于表示数据流路径
import TemplateInjectionFlow::PathGraph

// 从路径图中选择源节点和汇节点
from TemplateInjectionFlow::PathNode source, TemplateInjectionFlow::PathNode sink
// 条件：存在从源节点到汇节点的流动路径
where TemplateInjectionFlow::flowPath(source, sink)
// 选择汇节点、源节点及其相关信息，并生成警告信息
select sink.getNode(), source, sink, "This template construction depends on a $@.",
  source.getNode(), "user-provided value"
