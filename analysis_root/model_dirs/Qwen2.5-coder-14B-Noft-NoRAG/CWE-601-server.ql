import python

/**
 * This query detects CWE-601: URL Redirection to Untrusted Site ('Open Redirect').
 * It identifies cases where user input is used to construct a URL for redirection without validation.
 */

from CallExpr call, Expr userInput, Expr url
where call.getCallee().getName() = "redirect" and
      call.getArgument(0) = url and
      url instanceof StringLiteral or
      url instanceof BinaryExpr and
      (url.getLeftOperand() instanceof StringLiteral or
       url.getRightOperand() instanceof StringLiteral) and
      exists(Expr input : userInput |
             call.getArgument(1) = input or
             (input instanceof CallExpr and
              input.getCallee().getName() = "request" and
              input.getArgument(0).toString() = "GET"))
select call, "Potential CWE-601: URL redirection based on unvalidated user input."