import python

from HttpResponse response, Expr userInput, Expr outputExpr
where response.getBody().contains(outputExpr) and
      outputExpr instanceof StringLiteral and
      userInput instanceof Call and
      userInput.getCallee().getName() = "request.args.get" and
      outputExpr.getStringValue() = userInput.getArgument(0).getStringValue()
select response, "This response writes user input directly to the web page, which may lead to a reflected XSS vulnerability."