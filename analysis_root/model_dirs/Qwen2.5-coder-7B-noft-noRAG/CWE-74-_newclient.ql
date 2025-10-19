import python // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.ReflectedXssQuery // 导入与反射型跨站脚本（XSS）相关的查询模块
import ReflectedXssFlow::PathGraph // 导入路径图模块，用于表示数据流路径

// 从路径图中选择源节点和汇节点
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where ReflectedXssFlow::flowPath(source, sink)
// 选择汇节点、源节点、路径信息，并生成描述信息
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.",  source.getNode(), "user-provided value"