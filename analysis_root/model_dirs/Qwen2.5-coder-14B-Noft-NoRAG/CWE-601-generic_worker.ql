import python

from FunctionCall fc, Expr userInput, Expr redirectUrl
where fc.getCallee().getName() = "redirect"
  and fc.getArgument(0) = userInput
  and userInput instanceof ExternalFunctionCall
  and userInput.getCallee().getName() = "get"
select redirectUrl, "URL redirection based on unvalidated user input detected."