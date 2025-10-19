/**
 * @name Clear-text logging of sensitive information
 * @description Detects when sensitive data is logged without proper encryption,
 *              potentially exposing confidential information to unauthorized access.
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

// 导入Python分析库
import python
// 导入数据流分析框架
private import semmle.python.dataflow.new.DataFlow
// 导入路径图生成工具
import CleartextLoggingFlow::PathGraph
// 导入明文日志检测查询
import semmle.python.security.dataflow.CleartextLoggingQuery

// 定义查询变量：数据源点、目标点和数据分类
from
  CleartextLoggingFlow::PathNode originPoint, 
  CleartextLoggingFlow::PathNode destinationPoint, 
  string dataCategory
where
  // 验证存在从源点到目标点的数据流路径
  CleartextLoggingFlow::flowPath(originPoint, destinationPoint)
  and
  // 提取源点的数据分类信息
  dataCategory = originPoint.getNode().(Source).getClassification()
select 
  // 输出目标节点、源节点、目标节点、警告消息、源节点及其数据分类
  destinationPoint.getNode(), 
  originPoint, 
  destinationPoint, 
  "This expression logs $@ as clear text.", 
  originPoint.getNode(),
  "sensitive data (" + dataCategory + ")"