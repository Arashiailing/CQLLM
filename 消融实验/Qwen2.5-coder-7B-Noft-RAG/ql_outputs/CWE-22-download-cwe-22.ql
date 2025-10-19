/**
* @name Uncontrolled data used in path expression
*
@id py/download-cwe-22
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Call to " + externalApi.toString() + " with untrusted data
from $@.", source.getNode(), source.toString