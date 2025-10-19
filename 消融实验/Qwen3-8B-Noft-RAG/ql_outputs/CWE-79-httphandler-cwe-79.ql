@name Reflected server-side cross-site scripting
@id py/httphandler-cwe-79
import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Writing user input directly to a web page allows for a cross-site scripting vulnerability.", source.getNode(), "user-provided value"