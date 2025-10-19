/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/settings
 */
import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
where CleartextStorageFlow::flowPath(source, sink)
  and classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "This expression exposes $@ as clear text.", source.getNode(), 
     "sensitive data (" + classification + ")"