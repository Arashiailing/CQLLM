/**
 * @name CWE-125: Out-of-bounds Read
 * @id py/Grammar
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential out-of-bounds read using $@.", source.getNode()