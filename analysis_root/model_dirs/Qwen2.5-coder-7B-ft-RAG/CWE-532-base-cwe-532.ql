/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/base-cwe-532
 * @tags security
 */

// 导入Python库，用于分析Python代码
import python

// 导入数据流分析库
private import semmle.python.dataflow.new.DataFlow

// 导入日志记录查询类
import CleartextLoggingQuery

// 导入路径图类
import CleartextLoggingFlow::PathGraph

// 定义查询，查找日志记录的潜在路径
from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where  
  // 检查是否存在从源节点到汇节点的流动路径
  CleartextLoggingFlow::flowPath(source, sink) and
  // 获取源节点的分类信息
  classification = source.getNode().(Source).getClassification()
select 
  // 选择汇节点、源节点、汇节点、日志消息、源节点及其分类信息
  sink.getNode(), source, sink, "This expression logs $@ as clear text.", source.getNode(),
  "sensitive data (" + classification + ")"