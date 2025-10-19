import python

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/logout
 */

// Find calls to redirect functions that take user-controlled parameters
predicate isRedirectCall(Call call) {
  let func = call.getDecl()
  (func.getName() = "redirect" and 
   call.getArg(0).getType().getName() = "str" and 
   exists(Source s | s.getLocation() = call.getArg(0).getLocation()))
}

// Check for direct assignment of user input to Location header
predicate setLocationHeader(Call call) {
  let func = call.getDecl()
  (func.getName() = "set_header" or func.getName() = "headers") and
  call.getArg(0).getValue().getStringLiteral() = "Location"
}

from Call c
where isRedirectCall(c) or setLocationHeader(c)
select c, "Potential URL redirection vulnerability due to unvalidated user input"