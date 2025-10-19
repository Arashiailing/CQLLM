import python

from HttpResponse resp, Expr userInput, Expr writeExpr
where resp.hasBody() and
      resp.getBody().containsExpr(writeExpr) and
      writeExpr.isStringConcatenation() and
      writeExpr.getAnArgument() = userInput and
      userInput.getType() instanceof StringType
select writeExpr, "This expression writes user input directly to the HTTP response, which may lead to a reflected XSS vulnerability."