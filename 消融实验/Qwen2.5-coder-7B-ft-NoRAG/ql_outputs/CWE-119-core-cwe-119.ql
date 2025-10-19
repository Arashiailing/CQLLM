/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @id py/core-cwe-119
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper restriction of operations within the bounds of a memory buffer", source.getNode(), "user-provided value"