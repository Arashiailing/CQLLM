/**
* @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
*
@id py/link-following
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Potential link resolution before file access detected."