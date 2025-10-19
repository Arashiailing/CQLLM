import python

from CallExpr call, Arg arg, Expr input, RefType refType
where call.getCallee().getName() = "redirect" and
      call.getArg(0) = arg and
      arg.getExpr() = input and
      input.getType() instanceof RefType and
      refType = input.getType().asRefType() and
      refType.getUnderlyingType() instanceof StringType
select call, "Potentially vulnerable URL redirection detected."