/**
 * @name 明文存储敏感信息
 * @description 检测未加密或哈希处理的敏感信息存储，这些存储可能使敏感信息暴露给攻击者。
 * 
 * 该查询识别应用程序中敏感数据以明文形式存储的情况，没有进行适当的加密或哈希处理。
 * 这种做法可能导致敏感信息泄露，违反数据保护最佳实践。
 * 
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

import python  // Python代码分析基础库
private import semmle.python.dataflow.new.DataFlow  // 数据流分析模块
import CleartextStorageFlow::PathGraph  // 敏感数据流路径图
import semmle.python.security.dataflow.CleartextStorageQuery  // 明文存储安全查询模块

from 
  CleartextStorageFlow::PathNode sensitiveDataSource,  // 敏感数据源节点
  CleartextStorageFlow::PathNode dataStoragePoint,     // 明文存储位置节点
  string dataClassification                           // 敏感数据分类标识
where 
  // 检查是否存在从数据源到存储位置的完整数据流路径，并获取敏感数据的分类类型
  CleartextStorageFlow::flowPath(sensitiveDataSource, dataStoragePoint)
  and
  dataClassification = sensitiveDataSource.getNode().(Source).getClassification()
select 
  dataStoragePoint.getNode(),                          // 报告位置：明文存储点
  sensitiveDataSource, dataStoragePoint,              // 数据流路径：源节点 -> 目标节点
  "This expression stores $@ as clear text.",          // 警告消息模板
  sensitiveDataSource.getNode(),                       // 消息参数：敏感数据源位置
  "sensitive data (" + dataClassification + ")"       // 敏感数据分类详情