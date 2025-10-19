/**
 * @name CWE CATEGORY: DEPRECATED: Pathname Traversal and Equivalence Errors
 * @id py/multifilesystem
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Path injection detected using untrusted data from $@", source.getNode()