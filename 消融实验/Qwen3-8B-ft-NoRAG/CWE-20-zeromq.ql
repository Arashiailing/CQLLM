import python

from CallExpr call
where (call.getCallee().getName() = "call" and
       call.getModule().getName() = "subprocess" and
       exists (Argument arg |
         arg.getCall() = call and
         arg.getName() = "shell" and
         arg.getValue() = true
       )) or
      (call.getCallee().getName() = "system" and
       call.getModule().getName() = "os")
select call, "Potential command injection via improper input validation"