/**
 * @name 明文存储敏感信息检测
 * @description 识别应用程序中未加密或哈希处理的敏感数据存储点，这些存储可能导致敏感信息泄露。
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
  CleartextStorageFlow::PathNode sinkNode,  // 明文存储位置节点
  string sensitiveDataType  // 敏感数据分类标识
where 
  // 检测完整的数据流路径并获取敏感数据分类
  CleartextStorageFlow::flowPath(sourceNode, sinkNode)
  and 
  sensitiveDataType = sourceNode.getNode().(Source).getClassification()
select 
  sinkNode.getNode(),  // 报告位置：明文存储点
  sourceNode, sinkNode,  // 数据流路径：源节点 -> 目标节点
  "This expression stores $@ as clear text.",  // 警告消息模板
  sourceNode.getNode(),  // 消息参数：敏感数据源位置
  "sensitive data (" + sensitiveDataType + ")"  // 敏感数据分类详情