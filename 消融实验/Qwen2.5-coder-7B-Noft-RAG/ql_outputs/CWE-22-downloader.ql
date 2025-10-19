/**
* @name Uncontrolled data used in path expression
*
@id py/downloader
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Download path depends on a $@.", source.getNode(), "user-provided value"