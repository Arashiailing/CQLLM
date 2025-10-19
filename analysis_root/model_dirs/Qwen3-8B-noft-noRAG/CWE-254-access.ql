import python

from Call call, Argument arg
where 
    call.getMethod().getName() in ("eval", "exec", "__import__") and
    arg.getPosition() = 0 and
    exists(Call inputCall |
        inputCall.getMethod().getName() = "input" and
        inputCall.getThis() = null and
        arg.getExpression() = inputCall.getArguments()[0]
    )
select call, "Potential code injection via eval/exec/__import__ with user input from input()."