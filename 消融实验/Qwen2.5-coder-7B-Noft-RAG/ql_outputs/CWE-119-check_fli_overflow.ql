/**
* @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
*
@description The product performs operations on a memory buffer, but it reads
from
    or writes to a memory location outside the buffer's intended boundary. * This may result in read
    or write operations on unexpected memory locations that could be linked to other variables, data structures,
    or internal program data.
*
@id py/check_fli_overflow
*/
import python
import semmle.python.security.dataflow.MemorySafetyQuery
from MemOp op, int bufferSize, int index
    where op.isRead()
    or op.isWrite()
    and op.getAddress() = ptr
    and ptr.getOffset() = index
    and ptr.getSize() = bufferSize
    and (index < 0
    or index >= bufferSize)
    select op, "Potential out-of-bounds memory access detected."