/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/settings
 */
import python
private import semmle.python.dataflow.new.DataFlow
import CleartextStorageFlow::PathGraph
import semmle.python.security.dataflow.CleartextStorageQuery

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
where CleartextStorageFlow::flowPath(source, sink) and
      classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "This expression stores $@ as clear text.", source.getNode(), 
     "credentials (" + classification + ")"