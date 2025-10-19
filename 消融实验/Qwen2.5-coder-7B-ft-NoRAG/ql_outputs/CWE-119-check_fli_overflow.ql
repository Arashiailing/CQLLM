/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * @id py/check_fli_overflow
 */

import python
import semmle.python.security.dataflow.MemoryBufferOverflowQuery

from MemoryBufferOverflowFlow::PathNode source, MemoryBufferOverflowFlow::PathNode sink
where MemoryBufferOverflowFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Memory buffer overflow detected at $@.", source.getNode(), "buffer boundary"