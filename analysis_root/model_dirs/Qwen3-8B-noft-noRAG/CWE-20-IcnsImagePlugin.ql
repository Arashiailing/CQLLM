import python

/** @name Path Injection */
from MethodCall mc, Argument arg, Expression expr
where mc.getMethodName() = "open" and
      mc.getArgument(0).isString() and
      expr = mc.getArgument(0).getValue() and
      expr.matches(".*\.\./.*") and
     !expr.matches(".*\/safe_dir\/.*")
select expr, "Potential Path Injection via unvalidated file path"