import python

from CallExpr call, Argument arg
where 
    (call.getTarget().getName() = "print" or call.getTarget().getName() = "write") 
    and call.getNumArgs() >= 1 
    and arg.isFromUserInput()
select call, "Potential reflected XSS: user input is directly output without escaping."