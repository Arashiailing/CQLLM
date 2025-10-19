import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Missing authorization check for resource access", source.getNode(), "unauthorized access"