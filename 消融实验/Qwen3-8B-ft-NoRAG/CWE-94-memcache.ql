import py

from py.FunctionCall call
where call.name in ("eval", "exec", "compile")
select call, "Potential code injection via eval/exec/compile with user input"