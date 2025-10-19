/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @id py/exception
 */
import python
import semmle.codeql.dataflow.DataFlow
import semmle.python.security.dataflow.BufferOverflowQuery

from Call call, Parameter param
where call.getFunction().getName() = "some_vulnerable_function" and
      param = call.getParameter(0) and
      param.getType().isPointerType() and
      param.getValue().getLength() < param.getType().getSize()
select call, "Potential buffer overflow due to improper bounds restriction."