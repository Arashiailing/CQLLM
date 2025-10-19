/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/path-injection
 */

// 导入Python库，用于分析Python代码
import python
// 导入路径注入查询模块，用于检测路径注入问题
import semmle.python.security.dataflow.PathInjectionQuery
// 导入路径注入流模块，用于路径流动分析
import PathInjectionFlow::PathGraph

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
// 条件：如果存在从源到汇点的路径流动
where PathInjectionFlow::flowPath(source, sink)
// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"