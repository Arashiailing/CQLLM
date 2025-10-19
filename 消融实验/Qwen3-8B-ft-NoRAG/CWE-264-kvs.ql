import python

from CallExpr call, Argument arg, LocalVar var
where 
  (call.getCallee().getName() = "os.system" or 
   call.getCallee().getName() = "subprocess.call" or 
   call.getCallee().getName() = "subprocess.run" or 
   call.getCallee().getName() = "subprocess.check_output" or 
   call.getCallee().getName() = "subprocess.Popen") and
  arg.getValue().getKind() = "string" and
  arg.getValue().getExpression() = var and
  var.getType().getName() = "str" and
  var.getInitializer() is StringLiteral
select call, "Potential command injection vulnerability: command argument is directly concatenated with user input"