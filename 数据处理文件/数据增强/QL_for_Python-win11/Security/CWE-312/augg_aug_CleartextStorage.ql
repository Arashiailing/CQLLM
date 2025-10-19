/**
 * @name 明文存储敏感信息
 * @description 检测敏感数据未经加密/哈希处理直接存储的漏洞
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
  "This expression stores $@ as clear text.", 
  sourceNode.getNode(), 
  "sensitive data (" + classification + ")"