import python
import semmle.python.security.dataflow.ReflectedXssQuery

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential reflected XSS vulnerability due to a $@.", source.getNode(), "user-provided value"