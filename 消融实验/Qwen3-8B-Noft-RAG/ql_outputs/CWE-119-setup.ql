/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @id py/setup
 */
import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.ControlFlow

from Call call, Argument arg, Expr expr
where 
  call.getMethod().getName() = "setitem" and 
  arg.getArgumentPosition() = 0 and 
  expr instanceof IntegerLiteral and 
  expr.getValue() >= 1024
select call, "Potential buffer overflow detected: array index exceeds 1024"