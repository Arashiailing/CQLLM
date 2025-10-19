/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/xhu
 */

// 导入Python库，用于分析Python代码
import python
// 导入外部API库，用于识别外部API调用
import semmle.python.security.dataflow.PathInjectionQuery
// 导入路径注入查询模块，用于检测路径注入问题
import semmle.python.security.dataflow.new/PathInjection
// 导入路径图类，用于表示数据流路径
import PathInjectionFlow::PathGraph

// 定义数据流源节点和汇节点的变量source和sink
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
// 使用where子句定义数据流路径的条件，即source到sink的路径
where PathInjectionFlow::flowPath(source, sink)
// select子句选择要返回的结果，包括sink节点、source节点、路径信息等
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"