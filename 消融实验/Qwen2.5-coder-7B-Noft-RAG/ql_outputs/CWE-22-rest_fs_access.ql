/**
* @name Uncontrolled data used in path expression
*
@description Accessing paths influenced by users can allow an attacker to access unexpected resources.
*
@id py/rest_fs_access
*/
import python
// 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery
// 导入路径注入查询模块
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
// 从路径注入流中导入路径节点类
    where PathInjectionFlow::flowPath(source, sink)
// 条件：如果存在从源到汇点的路径流动
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"