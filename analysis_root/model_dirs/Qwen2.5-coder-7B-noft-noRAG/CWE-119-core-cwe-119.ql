import python // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery // 导入路径注入查询模块，用于检测路径注入问题
import PathInjectionFlow::PathGraph // 从路径注入流中导入路径节点类import PathInjectionFlow::PathGraph

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 条件：如果存在从源到汇点的路径流动
where PathInjectionFlow::flowPath(source, sink)

// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink,  "Call to " + externalApi.toString() + " with untrusted data from $@.", source.getNode(),  source.toString()