/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @id py/pyfribidi
 */
import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.dataflow.MemoryBoundsCheck

from Call call, Argument arg, Value size, Value index
where
  call.getMethod().getName() = "getitem" and
  arg = call.getArgument(0) and
  size = arg.getSize() and
  index = call.getArgument(1) and
  index > size
select call, "Potential buffer overflow due to out-of-bounds array access."