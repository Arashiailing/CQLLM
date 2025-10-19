import python  // 导入python模块，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery  // 导入PathInjectionQuery模块，用于检测路径注入问题
import PathInjectionFlow::PathGraph  // 导入路径图模块，用于数据流分析

// 从PathInjectionFlow模块中导入PathNode类，表示数据流路径中的节点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
// 使用where子句定义数据流路径的条件，即source到sink的路径
where PathInjectionFlow::flowPath(source, sink)
// select子句选择要返回的结果，包括sink节点、source节点、路径信息等
select sink.getNode(), source, sink, "Call to " + externalApi.toString() + " with untrusted data from $@.", source.getNode(),  source.toString()