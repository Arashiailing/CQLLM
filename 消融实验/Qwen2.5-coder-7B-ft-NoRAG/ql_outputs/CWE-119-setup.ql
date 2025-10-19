/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @id py/setup
 */

import python
import semmle.python.security.dataflow.MemoryBufferOverreadQuery
import MemoryBufferOverreadFlow::PathGraph

from MemoryBufferOverreadFlow::PathNode source, MemoryBufferOverreadFlow::PathNode sink
where MemoryBufferOverreadFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Memory buffer overread detected at $@.", source.getNode(), "out-of-bounds operation"