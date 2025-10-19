import python

from Call call, StringLiteral str
where 
  (call.getCallee().getName() = "subprocess.run" or 
   call.getCallee().getName() = "os.system" or 
   call.getCallee().getName() = "subprocess.check_output") and
  exists(Argument arg | call.getArguments() = arg and
    (arg.getValue().getExpression().toString() = str.toString() or
     arg.getValue().getExpression().toString().contains(str.toString()) and
     str.toString().startsWith("'") and str.toString().endsWith("'")) and
    not arg.getValue().getExpression().toString().contains("shlex.quote") and
    not arg.getValue().getExpression().toString().contains("pipes.quote"))
select call, "Potential Command Injection via unquoted external input"