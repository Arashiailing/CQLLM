/**
 * @name Uncontrolled data used in path expression
 * @id py/file
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"