import python

from Call call, Argument arg, Call getCall
where 
    call.getCallee().getName() = "redirect" and 
    arg.getValue() = getCall and 
    getCall.getMethod().getName() = "get" and 
    getCall.getReceiver().getType().getName() = "Request" and 
    not exists (call.getArguments()[0].getValue().getDefinition().getKind() = "Literal")
select call.getLocation(), "Potential URL redirection using untrusted input from request arguments"