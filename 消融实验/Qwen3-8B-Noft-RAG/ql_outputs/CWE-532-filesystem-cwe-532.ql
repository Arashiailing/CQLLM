import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink
where CleartextLoggingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This expression logs sensitive data as clear text", source.getNode()