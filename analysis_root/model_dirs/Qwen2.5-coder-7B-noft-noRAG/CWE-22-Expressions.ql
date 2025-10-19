import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
// 条件：如果存在从源到汇点的路径流动
where PathInjectionFlow::flowPath(source, sink)
// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  source.toString()