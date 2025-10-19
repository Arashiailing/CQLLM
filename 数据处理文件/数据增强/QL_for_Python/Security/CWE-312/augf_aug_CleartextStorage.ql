/**
 * @name 明文存储敏感信息
 * @description 敏感数据在未加密或哈希处理的情况下直接存储，可能导致信息泄露风险
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

import python
private import semmle.python.dataflow.new.DataFlow
import CleartextStorageFlow::PathGraph
import semmle.python.security.dataflow.CleartextStorageQuery

from 
  CleartextStorageFlow::PathNode sourceNode, 
  CleartextStorageFlow::PathNode sinkNode, 
  string classification
where 
  CleartextStorageFlow::flowPath(sourceNode, sinkNode) and
  classification = sourceNode.getNode().(Source).getClassification()
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "此表达式将 $@ 以明文形式存储。", 
  sourceNode.getNode(), 
  "敏感数据 (" + classification + ")"