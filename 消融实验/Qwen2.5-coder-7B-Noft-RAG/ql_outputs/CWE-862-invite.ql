/**
* @name CWE-862: Missing Authorization
*
@description The product does not perform an authorization check when an act
    or attempts to access a resource
    or perform an action.
*
@id py/invite
*/
import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
    where ReflectedXssFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Missing authorization check detected."