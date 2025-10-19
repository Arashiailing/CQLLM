/**
 * @name 敏感信息明文存储检测
 * @description 识别系统中以明文形式存储敏感数据的安全问题，这些数据未经加密或哈希处理，
 *              可能导致敏感信息泄露给未授权访问者。
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/clear-text-storage-sensitive-data
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-315
 *       external/cwe/cwe-359
 */

import python  // 导入Python代码分析基础库
private import semmle.python.dataflow.new.DataFlow  // 私有导入数据流分析模块
import CleartextStorageFlow::PathGraph  // 导入敏感数据流路径图
import semmle.python.security.dataflow.CleartextStorageQuery  // 导入明文存储安全查询模块

from 
  CleartextStorageFlow::PathNode sourceNode,  // 敏感数据源节点
  CleartextStorageFlow::PathNode sinkNode,    // 明文存储位置节点
  string dataCategory                         // 敏感数据分类标识
where 
  // 验证存在从数据源到存储位置的完整数据流路径
  CleartextStorageFlow::flowPath(sourceNode, sinkNode)
  and 
  // 提取敏感数据的具体分类类型
  dataCategory = sourceNode.getNode().(Source).getClassification()
select 
  sinkNode.getNode(),                    // 报告位置：明文存储点
  sourceNode, sinkNode,                  // 数据流路径：源节点 -> 目标节点
  "This expression stores $@ as clear text.",  // 警告消息模板
  sourceNode.getNode(),                  // 消息参数：敏感数据源位置
  "sensitive data (" + dataCategory + ")"  // 敏感数据分类详情