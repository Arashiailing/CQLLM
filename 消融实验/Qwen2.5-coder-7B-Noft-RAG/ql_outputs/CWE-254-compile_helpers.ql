import python
import semmle.python.security.dataflow.NanQuery
from NanFlow::PathNode source, NanFlow::PathNode sink
    where NanFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "NAN vulnerability detected.", source.getNode(), "user-supplied input"