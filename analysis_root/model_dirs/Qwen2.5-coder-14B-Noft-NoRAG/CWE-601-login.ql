import python

/**
 * Detects CWE-601: URL redirection from remote source
 */
from FunctionCall redirectCall, Expr userInputExpr, Expr redirectUrlExpr
where redirectCall.getCallee().getName() = "redirect" and
      redirectCall.getArgument(0) = userInputExpr and
      redirectCall.getArgument(1) = redirectUrlExpr and
      userInputExpr instanceof Call and
      userInputExpr.getCallee().getName() = "get" and
      userInputExpr.getArgument(0) instanceof StringLiteral
select redirectCall, "This URL redirection is based on unvalidated user input, which may cause redirection to malicious web sites."