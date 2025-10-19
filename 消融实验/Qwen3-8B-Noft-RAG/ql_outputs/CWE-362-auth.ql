/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization
 * @id py/auth
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential race condition due to uncontrolled data flow from $@.", source.getNode()