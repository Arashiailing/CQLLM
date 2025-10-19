/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/reflective-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// 导入Python库
import python
// 导入跨站脚本数据流分析模块
import semmle.python.security.dataflow.ReflectedXssQuery
// 导入路径图模块
import ReflectedXssFlow::PathGraph

// 定义数据流源节点和汇节点变量
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
// 过滤条件：存在从源节点到汇节点的数据流路径
where ReflectedXssFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.", 
  source.getNode(), "user-provided value"