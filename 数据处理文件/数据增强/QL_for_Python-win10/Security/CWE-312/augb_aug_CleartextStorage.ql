/**
 * @name 明文存储敏感信息
 * @description 检测敏感信息未经加密或哈希处理直接存储的安全漏洞
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
  string classificationType
where 
  CleartextStorageFlow::flowPath(sourceNode, sinkNode) and
  exists(string classification |
    classification = sourceNode.getNode().(Source).getClassification() and
    classificationType = classification
  )
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This expression stores $@ as clear text.", 
  sourceNode.getNode(), 
  "sensitive data (" + classificationType + ")"