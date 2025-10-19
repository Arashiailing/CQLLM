import python

from FunctionCall call, Expr userInput, Expr redirectUrl
where call.getCallee().getName() = "redirect" and
      call.getArgument(0) = userInput and
      not exists(Expr validation | validation.getAChild() = userInput)
select call, "This function call redirects to a URL based on unvalidated user input, which may lead to CWE-601: URL Redirection to Untrusted Site."