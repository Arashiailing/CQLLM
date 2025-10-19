import python

from CallExpr call
where call.getCallee().getName() = "float" and call.getArgument(0).getType().isString()
select call, "Potential CWE-681: Incorrect conversion between numeric types (unhandled string-to-float conversion)"