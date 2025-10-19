/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description nan
 * @kind path-problem
 * @id py/settings
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
where
  CleartextStorageFlow::flowPath(source, sink) and
  classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "This expression stores $@ as clear text.", source.getNode(),
  "sensitive data (" + classification + ")"