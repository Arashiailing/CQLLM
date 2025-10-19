import python  // 导入Python库，用于处理Python代码的解析和分析
import CleartextLoggingFlow::PathGraph  // 导入CleartextLoggingFlow的路径图类
import semmle.python.security.dataflow.CleartextLoggingQuery  // 导入CleartextLoggingQuery模块，用于处理明文日志相关的查询

// 从CleartextLoggingFlow中选择源节点和汇节点，并获取分类信息
from  CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where  // 检查是否存在从源节点到汇节点的流动路径
  CleartextLoggingFlow::flowPath(source, sink) and
  // 获取源节点的分类信息
  classification = source.getNode().(Source).getClassification()
select  // 选择汇节点、源节点、汇节点、日志消息、源节点及其分类信息
  sink.getNode(), source, sink, "This expression logs $@ as clear text.", source.getNode(),  "sensitive data (" + classification + ")"