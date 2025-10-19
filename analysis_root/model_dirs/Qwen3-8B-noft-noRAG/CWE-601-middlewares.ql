import py

/**
 * Detects potential URL redirection vulnerabilities where user input is used to construct a redirect URL without validation.
 */
from Call c, StringLiteral sl
where 
  (c.getCallee().getName() = "redirect" or 
   c.getCallee().getName() = "HttpResponseRedirect" or 
   c.getCallee().getName() = "Response") and
  c.getArg(0) = sl and
  sl.getValue().matches("^[a-zA-Z]+://") and
  sl.getValue().contains("user_input")
select c, "Potential URL redirection from unvalidated user input."