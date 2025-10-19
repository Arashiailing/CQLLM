import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
    where ReflectedXssFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This route handles user input directly, leading to potential cross-site scripting vulnerabilities."