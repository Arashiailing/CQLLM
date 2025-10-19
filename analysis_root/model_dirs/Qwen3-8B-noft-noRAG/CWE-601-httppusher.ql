import python

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/httppusher
 */
from Call redirectCall, Call userInputCall, StringLiteral urlPart
where 
    redirectCall.getCallee().getName() = "redirect" 
    and redirectCall.getArgument(0).getType().getName() = "str" 
    and userInputCall.getTarget() = "request.args.get" 
    and urlPart.getValue() like "%{%" 
    and redirectCall.getArgument(0) = urlPart 
select redirectCall, userInputCall, urlPart, "Potential URL redirection using unvalidated user input."