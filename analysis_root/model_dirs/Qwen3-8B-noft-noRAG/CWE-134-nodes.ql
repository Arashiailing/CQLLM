import python

from PyFunctionCall call, PyArg arg, PyVarLikeExpr var
where call.getArgs().has(arg)
  and arg.getPos() == 0
  and arg.getExpr() = var
  and not var.isConstant()
  and call.getName() in ("print", "logging.info", "logging.warning", "logging.error", "logging.debug")
select call, "Potential Log Injection due to externally-controlled format string"