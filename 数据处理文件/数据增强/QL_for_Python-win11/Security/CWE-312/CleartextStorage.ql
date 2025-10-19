/**
 * @name 明文存储敏感信息
 * @description 未加密或哈希处理的敏感信息存储可能会使其暴露给攻击者。
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

import python  // 导入Python库，用于分析Python代码
private import semmle.python.dataflow.new.DataFlow  // 私有导入数据流分析库
import CleartextStorageFlow::PathGraph  // 导入路径图类，用于跟踪数据流路径
import semmle.python.security.dataflow.CleartextStorageQuery  // 导入安全数据流查询类

from
  CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification  // 从源节点、目标节点和分类字符串中选择数据
where
  CleartextStorageFlow::flowPath(source, sink) and  // 条件：存在从源节点到目标节点的数据流路径
  classification = source.getNode().(Source).getClassification()  // 并且源节点的分类与给定的分类匹配
select sink.getNode(), source, sink, "This expression stores $@ as clear text.", source.getNode(),  // 选择目标节点、源节点、路径以及相关信息
  "sensitive data (" + classification + ")"  // 并附加说明该表达式以明文形式存储了敏感数据及其分类
