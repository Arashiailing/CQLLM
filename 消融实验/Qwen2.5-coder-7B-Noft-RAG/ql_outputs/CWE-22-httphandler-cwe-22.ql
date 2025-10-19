/**
* @name Uncontrolled data used in path expression
*
@id py/httphandler-cwe-22
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Call to function with untrusted data
from $@.", source.getNode(), source.toString()