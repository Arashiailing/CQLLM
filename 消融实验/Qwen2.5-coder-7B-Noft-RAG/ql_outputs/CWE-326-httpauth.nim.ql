python
import python
import semmle.python.security.dataflow.CleartextStorageQuery
import semmle.python.dataflow.new.DataFlow
import CleartextStorageFlow::PathGraph
import semmle.python.dataflow.new.FlowPath
from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
    where CleartextStorageFlow::flowPath(source, sink)
    and classification = source.getNode().(Source).getClassification()
    select sink.getNode(), source, sink, "This expression stores $@ as clear text.", source.getNode(), "sensitive data (" + classification + ")"