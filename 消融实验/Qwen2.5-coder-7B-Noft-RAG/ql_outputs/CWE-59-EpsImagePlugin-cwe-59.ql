/**
* @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
*
@description nan
*
@id py/link-resolution-before-file-access
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper link resolution before file access detected."