/**
 * @name 明文存储敏感信息
 * @description 检测未加密或哈希处理的敏感信息存储，这些存储可能使敏感信息暴露给攻击者。
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
  CleartextStorageFlow::PathNode dataOrigin,  // 敏感数据源节点
  CleartextStorageFlow::PathNode storageLocation,  // 明文存储位置节点
  string dataCategory  // 敏感数据分类标识
where 
  // 确保存在从数据源到存储位置的完整数据流路径
  CleartextStorageFlow::flowPath(dataOrigin, storageLocation)
  and 
  // 获取并匹配敏感数据的具体分类类型
  dataCategory = dataOrigin.getNode().(Source).getClassification()
select 
  storageLocation.getNode(),  // 报告位置：明文存储点
  dataOrigin, storageLocation,  // 数据流路径：源节点 -> 目标节点
  "This expression stores $@ as clear text.",  // 警告消息模板
  dataOrigin.getNode(),  // 消息参数：敏感数据源位置
  "sensitive data (" + dataCategory + ")"  // 敏感数据分类详情