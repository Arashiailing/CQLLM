import python

from HttpResponse httpResponse, Expr userInput, CallExpr call
where httpResponse.getMethod() = "write" and
      userInput instanceof HttpRequestParameter and
      call.getCallee().getName() = "write" and
      call.getArgument(0) = userInput
select call, "This call to httpResponse.write() may reflect user input, leading to a reflected XSS vulnerability."