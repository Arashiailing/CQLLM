import py

/**
 * @name CWE-684: Incorrect Provision of Specified Functionality (UrlRedirect)
 */
from Call call, StringLiteral sl
where 
  call.getTarget().getName() = "redirect" and 
  call.getArgument(0) = sl and 
  sl.getValue().matches("^(https?://)?[^\\s/$.?#][^$&]*$") = false
select sl, "Potential URL redirection vulnerability detected with unvalidated input"

import py

/**
 * @name CWE-684: Incorrect Provision of Specified Functionality (UrlRedirect)
 */
from Call call, Argument arg
where 
  call.getTarget().getKind() = "function" and 
  call.getTarget().getName().matches(".*redirect.*") and 
  arg.getType().isString() and 
  exists(Variable var where var.isInputParameter() and var.getUsage() = arg)
select arg, "Potential URL redirection vulnerability detected with unvalidated input"

import py

/**
 * @name CWE-684: Incorrect Provision of Specified Functionality (UrlRedirect)
 */
from Call call, Assignment assign, StringLiteral sl
where 
  call.getTarget().getName() = "send_response" or 
  call.getTarget().getName() = "set_header" and 
  assign.getLeftHandSide() = call and 
  assign.getRightHandSide() = sl and 
  sl.getValue().matches("^Location:.*") and 
  sl.getValue().contains("/") and 
  sl.getValue().matches("^[^\\s]+://[^\\s/]+/[^\"]*$") = false
select sl, "Potential URL redirection vulnerability detected through response header manipulation"