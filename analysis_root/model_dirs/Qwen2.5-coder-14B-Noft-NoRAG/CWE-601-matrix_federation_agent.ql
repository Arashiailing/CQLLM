import python

from Function f, CallExpr call, Expr input, Expr redirectUrl
where
  f.getName() = "redirect" and
  call.getCallee() = f and
  input = call.getArgument(0) and
  redirectUrl = call.getArgument(1) and
  not exists(Expr validation | validation = input.getAncestor(Expr) and validation.getType() instanceof BoolType)
select redirectUrl, "Unvalidated user input used for URL redirection"