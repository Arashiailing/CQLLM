import python

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/media_repository
 */
from PyCall call, PyFunctionDef func, PyArgument arg
where 
  func.name = "redirect" and
  call.getModule().getName() = "flask" and
  arg.getValue().toString() = "request.args.get('redirect_url')"
select call, "Potential URL redirection based on unvalidated user input"