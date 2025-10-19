/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page
 *              allows for a cross-site scripting vulnerability.
 * @id py/app-cwe-79
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @security-severity 6.1
 * @tags security
 *       external/cwe/cwe-079
 */

// 导入Python标准库
import python
// 导入跨站脚本查询模块
import semmle.python.security.dataflow.ReflectedXssQuery
// 导入路径图模块，用于表示数据流路径
import ReflectedXssFlow::PathGraph

// 定义源节点和汇节点变量
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where ReflectedXssFlow::flowPath(source, sink)

// 选择汇节点、源节点、路径信息，并生成描述信息
select sink.getNode(), source, sink,
  "$@ reaches a web page and is subsequently written to it.",
  source, source.toString(),
  sink.getNode(), "User-provided value"