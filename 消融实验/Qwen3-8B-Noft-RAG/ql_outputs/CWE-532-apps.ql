import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink, string classification
where CleartextLoggingFlow::flowPath(source, sink) and
      classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "This expression logs $@ as clear text.", source.getNode(), "sensitive data (" + classification + ")"