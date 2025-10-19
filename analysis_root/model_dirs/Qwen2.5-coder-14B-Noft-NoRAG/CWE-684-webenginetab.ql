import python
import semmle.python.frameworks.web

/**
 * CWE-684: Incorrect Provision of Specified Functionality
 * Query to detect potential URL redirection vulnerabilities
 */

from FlaskRequestHandler requestHandler, Expr redirectExpr
where requestHandler.getEndpoint().isGET() and
      redirectExpr instanceof Call and
      redirectExpr.getCallee().getName() = "redirect" and
      redirectExpr.getArgument(0) instanceof Call and
      redirectExpr.getArgument(0).getCallee().getName() = "request.args.get"
select redirectExpr, "Potential URL redirection vulnerability detected. The'redirect' function is called with user-supplied input from'request.args.get'."