import py

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/modules
 */
from Call call, Argument arg
where 
  call.getCallee().getName() = "redirect" and 
  arg.getArgumentPosition() = 0 and 
  arg.getExpression().isString() and 
  arg.getExpression().getValue() = "user_input"
select call, "Potential URL redirection based on unvalidated user input"