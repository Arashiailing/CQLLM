/**
 * @name CWE CATEGORY: DEPRECATED: Pathname Traversal and Equivalence Errors
 * @kind path-problem
 * @id py/filesystem-cwe-21
 * @deprecated
 */

// 导入Python库，用于分析Python代码
import python

// 导入路径注入查询模块，用于检测路径注入问题
import semmle.python.security.dataflow.PathInjectionQuery

// 导入路径图类，用于表示数据流路径
import PathInjectionFlow::PathGraph

// 从路径图中选择源节点和汇节点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where PathInjectionFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This path depends on a $@", source.getNode(), "user-provided value"