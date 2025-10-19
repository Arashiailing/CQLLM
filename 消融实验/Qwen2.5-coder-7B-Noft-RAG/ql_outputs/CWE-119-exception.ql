/**
* @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
*
@description The product performs operations on a memory buffer, but it reads
from
    or writes to a memory location outside the buffer's intended boundary. * This may result in read
    or write operations on unexpected memory locations that could be linked to other variables, data structures,
    or internal program data.
*
@id py/buffer-overread-write
*/
import python
from ExprStmt stmt, VarAccess varAccess, MemBuffer memBuf, IntLit index, IntLit length
    where stmt.getExpr() = varAccess
    and varAccess.getTarget() = memBuf
    and exists(IntLit idx | idx = index
    and idx.getValue() >= 0
    and idx.getValue() < length.getValue())
    select stmt, "Memory buffer operation out of bounds."