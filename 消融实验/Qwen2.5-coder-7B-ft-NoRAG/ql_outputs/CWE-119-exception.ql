/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/memory-buffer-boundary-violation
 */

import python

from MemoryAccess memAcc, Variable var, Expr expr
where
  memAcc.getTarget() = var and
  not (memAcc.getStartByteOffset() >= 0 and memAcc.getEndByteOffset() <= var.getType().getSize())
select memAcc, "Memory buffer boundary violation detected."