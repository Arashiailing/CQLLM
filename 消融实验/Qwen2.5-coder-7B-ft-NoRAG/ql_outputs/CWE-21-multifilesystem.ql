/**
 * @name CWE-21: Path Injection Query
 * @category Deprecated: Pathname Traversal and Equivalence Errors
 * @description Path injection occurs when untrusted data is used in a pathname expression.
 * @id py/path-injection
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"