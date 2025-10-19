/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @id py/pyfribidi
 */

import python
import semmle.python.memory.MemorySafety

from MemoryAccess access
where access.isOutOfBounds()
select access, "Memory operation out of bounds."