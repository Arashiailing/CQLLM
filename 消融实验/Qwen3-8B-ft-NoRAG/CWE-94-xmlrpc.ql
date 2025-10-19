import py

from Call c
where c.getFunction().getName() in ["eval", "exec"]
  and c.getArgument(0).getType().isString()
select c, "Potential code injection via eval/exec with user input"