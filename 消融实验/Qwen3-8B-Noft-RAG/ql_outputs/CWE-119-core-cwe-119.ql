/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @id py/core-cwe-119
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Memory buffer operation uses untrusted data from $@.", source.getNode(), "user-provided value"