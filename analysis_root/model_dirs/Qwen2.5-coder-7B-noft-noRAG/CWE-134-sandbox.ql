</think>

import python // 导入python库
import semmle.python.security.dataflow.CommandInjectionQuery // 导入CommandInjectionQuery查询模块
import CommandInjectionFlow::PathGraph // 导入CommandInjectionFlow路径图模块

// 从CommandInjectionFlow路径图中选择源节点和汇节点
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
// 条件：存在从源节点到汇节点的路径
where CommandInjectionFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇节点信息、描述信息等
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),  // 描述信息：该命令行依赖于用户提供的值
  "user-provided value"