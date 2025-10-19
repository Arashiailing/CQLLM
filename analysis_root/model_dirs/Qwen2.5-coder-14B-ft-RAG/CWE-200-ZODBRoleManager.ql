/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/ZODBRoleManager
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageQuery::PathGraph

from
  CleartextStorageQuery::PathNode source,
  CleartextStorageQuery::PathNode sink,
  string sensitiveDataType
where
  CleartextStorageQuery::flowPath(source, sink)
  and
  sensitiveDataType = source.getNode().(Source).getClassification()
select sink.getNode(),
  source,
  sink,
  "This expression stores $@ as clear text.", 
  source.getNode(),
  "'$@'", 
  sensitiveDataType