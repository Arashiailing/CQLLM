/**
 * 检测CWE-264: StackTraceExposureQuery
 */
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

// 从路径图中选择源节点和汇节点
from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
// 条件：如果存在从源节点到汇节点的路径流动
where StackTraceExposureFlow::flowPath(source, sink)
// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "This stack trace exposes a $@.", source.getNode(),
  "user-supplied value"