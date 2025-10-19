import python // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.CommandInjectionQuery // 导入命令注入查询模块
import CommandInjectionFlow::PathGraph // 导入命令注入路径图类，用于表示数据流路径

// 从命令注入路径图中选择源节点和汇节点
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
// 条件：存在从源节点到汇节点的路径
where CommandInjectionFlow::flowPath(source, sink)
// 选择汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),  // 描述信息：该命令行依赖于用户提供的值
  "user-provided value"