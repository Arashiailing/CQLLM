/**
* @name Reflected server-side cross-site scripting
*
@description Writing user input directly to a web page allows f
    or a cross-site scripting vulnerability.
*
@id py/ZRPythonExpr
*/
import python
import semmle.python.security.dataflow.ReflectedXssQuery
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
    where ReflectedXssFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This web page outputs user-provided data without proper encoding."