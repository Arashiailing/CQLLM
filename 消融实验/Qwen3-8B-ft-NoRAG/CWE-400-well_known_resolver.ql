import python

from WhileStmt w
where w.condition = true
select w, "Potential infinite loop due to constant true condition"

from FunctionCall fc
where fc.function = fc.receiver
select fc, "Potential uncontrolled recursion"

from Call call
where call.function = "eval" or call.function = "exec"
select call, "Potential resource consumption via eval/exec"