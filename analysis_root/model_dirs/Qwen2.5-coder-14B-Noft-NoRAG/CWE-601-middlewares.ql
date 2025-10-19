import python

from HttpRequest import HttpRequest
from HttpResponse import HttpResponse
from Expr import Expr
from Function import Function

class UnvalidatedUrlRedirect extends Function {
  UnvalidatedUrlRedirect() {
    exists(HttpRequest req, HttpResponse resp, Expr urlExpr |
      this.getAParameter().getDeclaringType().hasName("HttpRequest") and
      this.getAParameter().getDeclaringType().hasName("HttpResponse") and
      this.getBody().getStmts().contains(resp) and
      resp.getExpr().getArgs().contains(urlExpr) and
      not urlExpr instanceof ValidatedInput
    )
  }
}

from UnvalidatedUrlRedirect func
select func, "This function may be vulnerable to CWE-601: URL redirection from remote source due to unvalidated user input."