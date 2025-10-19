/**
 * @name Clear-text logging of sensitive information
 * @description Logging sensitive information without encryption or hashing can
 *              expose it to an attacker.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/clear-text-logging-sensitive-data
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-359
 *       external/cwe/cwe-532
 */

// 导入Python库
import python
// 导入数据流分析库
private import semmle.python.dataflow.new.DataFlow
// 导入路径图类
import CleartextLoggingFlow::PathGraph
// 导入明文日志查询类
import semmle.python.security.dataflow.CleartextLoggingQuery

// 从CleartextLoggingFlow中获取源节点和汇节点，以及分类信息
from
  CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where
  // 检查是否存在从源节点到汇节点的流动路径
  CleartextLoggingFlow::flowPath(source, sink) and
  // 获取源节点的分类信息
  classification = source.getNode().(Source).getClassification()
select 
  // 选择汇节点、源节点、汇节点、日志消息、源节点及其分类信息
  sink.getNode(), source, sink, "This expression logs $@ as clear text.", source.getNode(),
  "sensitive data (" + classification + ")"
