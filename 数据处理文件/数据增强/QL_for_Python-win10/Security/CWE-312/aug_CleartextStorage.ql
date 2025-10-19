/**
 * @name 明文存储敏感信息
 * @description 敏感信息未经加密或哈希处理直接存储，可能被攻击者获取
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
  CleartextStorageFlow::PathNode sensitiveSource, 
  CleartextStorageFlow::PathNode storageSink, 
  string dataClassification
where 
  CleartextStorageFlow::flowPath(sensitiveSource, storageSink) and
  dataClassification = sensitiveSource.getNode().(Source).getClassification()
select 
  storageSink.getNode(), 
  sensitiveSource, 
  storageSink, 
  "This expression stores $@ as clear text.", 
  sensitiveSource.getNode(), 
  "sensitive data (" + dataClassification + ")"