/**
* @name Reflected server-side cross-site scripting
*
@description Writing user input directly to a web page allows f
    or a cross-site scripting vulnerability.
*
@id py/registration
*/
import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
    where ReflectedXssFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.", source.getNode(), "user-provided value"