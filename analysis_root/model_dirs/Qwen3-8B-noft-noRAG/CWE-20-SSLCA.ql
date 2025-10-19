import python

from Call call, Argument arg, Function func
where call.getCallee().getName() in ("eval", "exec", "os.system", "subprocess.check_output") 
  and arg.getIndex() = 0 
  and arg.getExpression() is Variable var 
  and var.getDefinition() is Call def_call 
  and def_call.getCallee().getName() = "input"
select call, "Potential CWE-20: Unvalidated user input used in dangerous function"