/**
* @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
*
@id py/setup
*/
import python
import semmle.python.security.dataflow.MemorySafetyQuery
from MemorySafetyFlow::PathNode source, MemorySafetyFlow::PathNode sink
    where MemorySafetyFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Memory operation out of bounds."