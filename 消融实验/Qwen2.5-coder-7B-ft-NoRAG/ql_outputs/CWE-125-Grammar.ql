/**
 * @name CWE-125: Out-of-bounds Read
 * @id py/Grammar
 */

import python

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bounds read detected at $@.", source.getNode(), "user-provided value"