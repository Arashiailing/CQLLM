import py

from Call call, StringLiteral str, Variable var
where (call.getCallee().getName() = "subprocess.run" or 
       call.getCallee().getName() = "subprocess.call" or 
       call.getCallee().getName() = "os.system" or 
       call.getCallee().getName() = "subprocess.Popen") and 
      (call.getArg(0).getExpression() = str or 
       call.getArg(0).getExpression() = var) and 
      (call.getArg(0).getExpression() instanceof StringLiteral or 
       call.getArg(0).getExpression() instanceof Variable)
select call, "Potential command injection via command execution with user-controlled input."