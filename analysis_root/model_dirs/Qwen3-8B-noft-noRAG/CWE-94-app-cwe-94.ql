import python

from Call c, Argument arg
where (c.getCallee().getName() = "eval" or c.getCallee().getName() = "exec")
  and arg is the firstArgument of c
  and arg.getType().isString()
select c, "Potential code injection via dynamic evaluation with untrusted input"