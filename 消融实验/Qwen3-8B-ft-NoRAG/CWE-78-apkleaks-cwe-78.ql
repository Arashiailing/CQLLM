import py

from CallExpr import CallExpr
from py::Function import Function

select CallExpr
where
  (CallExpr.getFunction() is Function
   and
   Function.getName() in ["run", "call", "check_call", "check_output", "Popen"]
   and
   CallExpr.getArgument(0).isString()
   and
   (CallExpr.getArgument(1).isKeyword("shell") and CallExpr.getArgument(1).getValue() is true)
   )
   or
   (CallExpr.getFunction() is Function
    and
    Function.getName() = "system"
    and
    CallExpr.getArgument(0).isString()
   )